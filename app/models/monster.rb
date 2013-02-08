class Monster < ActiveRecord::Base
  REMOVE_AFTER = 72.hours

  belongs_to  :character

  belongs_to :killer, :class_name => "Character"

  has_many    :monster_fights,
    :dependent => :delete_all

  has_many    :app_requests,
    :as => :target,
    :class_name => 'AppRequest::Base',
    :dependent => :delete_all

  state_machine :initial => :progress do
    state :progress
    state :won
    state :expired

    event :win do
      transition :progress => :won
    end

    event :expire do
      transition :progress => :expired
    end

    before_transition :on => :win do |monster|
      monster.defeated_at = Time.now
    end

    after_transition :on => [:win, :expire], :do => [:expire_app_requests, :update_fight_lists]
  end

  validates_presence_of :character, :monster_type

  before_create :assign_initial_attributes, :apply_fight_start_rewards
  after_create  :create_fight

  before_update :check_negative_health_points
  after_update  :check_winning_status

  def monster_type=(type)
    self[:monster_type_id] = type.id

    @monster_type = nil
  end

  def monster_type
    @monster_type ||= GameData::MonsterType[ self[:monster_type_id] ]
  end

  def damage
    @damage ||= DamageTable.new(self)
  end

  def time_remaining
    (expire_at - Time.now).to_i
  end

  def event_data
    {
      :reference_id => self.id,
      :reference_type => "Monster"
    }
  end

  validate :validate_monster, :on => :create

  def will_get_reward?(character)
    damage.reached_reward_minimum?(character) and
    damage.position(character) < monster_type.reward_collectors
  end

  def remove_at
    (defeated_at || expire_at) + REMOVE_AFTER
  end

  def chat_id
    "monster_%09d" % id
  end

  def fighters(exclude_character = nil)
    result = []

    $redis.zrevrangebyscore(fighters_key, Time.zone.now.to_i, 5.minutes.ago.to_i).each do |f|
      record = Marshal.load(f)

      result << record if exclude_character.nil? or record[0] != exclude_character.facebook_id

      break if result.size == 12
    end

    result
  end

  def add_fighter(character, damage)
    fighters.select{ |f| f[0] == character.facebook_id }.each{ |f| $redis.zrem(fighters_key, Marshal.dump(f)) }

    $redis.zadd(fighters_key, Time.zone.now.to_i, Marshal.dump([character.facebook_id, damage]))
  end

  def as_json_for(character)
    {
      :id             => id,
      :time_remaining => time_remaining,
      :hp             => hp,
      :state          => state,
      :leaders        => damage.leaders.as_json,
      :monster_type   => monster_type.as_json_for(character)
    }
  end

  protected

  def fighters_key
    "monster_#{ id }_fighters_key"
  end

  def assign_initial_attributes
    self.hp = health

    self.expire_at = monster_type.fight_time.hours.from_now
  end

  def apply_fight_start_rewards
    monster_type.apply_reward_on(:fight_start, character)
  end

  def validate_monster
    return unless character && monster_type

    errors.add(:base, :recently_attacked) if character.monster_fights.own.current.by_type(monster_type).count > 0

    errors.add(:character, :low_level) if level && character.level < level

    errors.add(:character, :requirements_not_satisfied) unless requirements(character).satisfied?
  end

  def create_fight
    monster_fights.create!(:character => character)
  end

  def check_negative_health_points
    self.hp = 0 if hp < 0
  end

  def check_winning_status
    win! if progress? and hp == 0
  end

  def expire_app_requests
    app_requests.for_expire.each do |app_request|
      app_request.expire!
    end
  end

  def update_fight_lists
    if won?
      monster_fights.each do |fight|
        fight.reward_collectable? ? fight.add_to_defeated_fights : fight.add_to_finished_fights
      end
    elsif expired?
      monster_fights.each do |fight|
        fight.add_to_finished_fights
      end
    end
  end
end
