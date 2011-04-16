class Statistics
  class Levels < self
    def default_scope
      @time_range ? Character.scoped(:joins => :user, :conditions => ["users.last_visit_at BETWEEN ? AND ?", @time_range.begin, @time_range.end]) : Character
    end
        
    def total
      scope.count
    end
    
    def average_values
      scope.all(
        :select => %{
          level, 
          COUNT(id) AS total, 
          AVG(total_money) AS basic_money,
          AVG(vip_money) AS vip_money,
          AVG(attack) AS attack,
          AVG(defence) AS defence,
          AVG(health) AS health,
          AVG(energy) AS energy,
          AVG(stamina) AS stamina,
          AVG(fights_won + fights_lost) AS fights,
          AVG(missions_succeeded) AS missions_succeeded,
          AVG(missions_mastered) AS missions_mastered,
          AVG(missions_completed) AS missions_completed,
          (SELECT count(relations.id) FROM relations WHERE character_id = characters.id AND type = 'MercenaryRelation') AS mercenaries,
          (SELECT count(relations.id) FROM relations WHERE character_id = characters.id AND type = 'FriendRelation') AS friends
        }, 
        :group  => :level
      ).collect do |record|
        OpenStruct.new.tap do |s|
          %w{level basic_money attack defence vip_money health energy stamina missions_succeeded missions_mastered missions_completed}.each do |attr|
            s.send("#{attr}=", record.send(attr))
          end
          
          %w{total mercenaries friends fights}.each do |attr|
            s.send("#{attr}=", record[attr].to_f.round)
          end
        end
      end
    end
  end
end
