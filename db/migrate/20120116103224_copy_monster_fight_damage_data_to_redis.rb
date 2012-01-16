class CopyMonsterFightDamageDataToRedis < ActiveRecord::Migration
  def self.up
    scope = Monster.scoped(:conditions => ["created_at > ?", 2.weeks.ago])

    total = scope.count

    puts "Updating monster fight damage score (#{ total } monsters)..."

    i = 0
    scope.find_each do |monster|
      monster.monster_fights.each do |fight|
        fight.send(:update_damage_score)
      end

      i += 1

      puts "Updated #{ i } of #{ total }..." if i % 100 == 0
    end

    puts "Done!"
  end

  def self.down
  end
end
