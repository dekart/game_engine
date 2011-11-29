class Rating
  FIELDS = %w{total_score fights_won killed_monsters_count total_monsters_damage total_money missions_succeeded level}
  
  
  class << self
    def schedule_update(character)
      $redis.hset('rating_updates', character.id, 
        Marshal.dump(character.rating_values)
      )
    end
    
    def scheduled_updates
      [].tap do |result|
        $redis.hgetall('rating_updates').each do |id, values|
          result << [id.to_i, Marshal.load(values)]
        end
      end
    end
    
    def fetch_scheduled_updates!
      scheduled_updates.tap do
        $redis.del('rating_updates')
      end
    end
    
    def process_scheduled_updates!
      updates = fetch_scheduled_updates!
      
      updates.each do |id, values|
        update(id, values)
      end
    end
    
    def update(id, values)
      values.each_with_index do |value, index|
        $redis.zadd(key(FIELDS[index]), value.to_i, id)
      end
    end
    
    def key(field)
      "rating_#{ field }"
    end
    
    def rebuild!
      clear!
      
      Character.find_each(:batch_size => 100) do |c|
        update(c.id, c.rating_values)
      end
    end
    
    def clear!
      FIELDS.each do |field|
        $redis.del(key(field))
      end
    end
  end
  
  
  attr_reader :field
  
  def initialize(field)
    @field = field
  end
  
  def key
    self.class.key(@field)
  end
  
  def leaders(limit)
    ranks = $redis.zrevrange(key, 0, limit - 1, :with_scores => true).map{|value| value.to_i }.in_groups_of(2)
    ids = ranks.map{|r| r[0] }

    Character.scoped(:include => :user).find_all_by_id(ids).tap do |characters|
      characters.map!{|c| [ranks.assoc(c.id)[1], c] }
      characters.sort!{|a,b| a[0] <=> b[0] }
      characters.reverse!
    end
  end
  
  def position(character)
    position = $redis.zrank(key, character.id) || -1

    $redis.zcard(key) - position
  end
end