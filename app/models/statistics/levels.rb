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

          MAX(total_money) AS basic_money_max,
          MAX(vip_money) AS vip_money_max,
          MAX(attack) AS attack_max,
          MAX(defence) AS defence_max,
          MAX(health) AS health_max,
          MAX(energy) AS energy_max,
          MAX(stamina) AS stamina_max,
          MAX(fights_won + fights_lost) AS fights_max,
          MAX(missions_succeeded) AS missions_succeeded_max,
          MAX(missions_mastered) AS missions_mastered_max,
          MAX(missions_completed) AS missions_completed_max
        }, 
        :group  => :level
      ).collect do |record|
        OpenStruct.new.tap do |s|
          %w{
            level 
            total
            basic_money
            attack
            defence
            vip_money
            health
            energy
            stamina
            fights
            missions_succeeded
            missions_mastered
            missions_completed
            basic_money_max
            attack_max
            defence_max
            vip_money_max
            health_max
            energy_max
            stamina_max
            fights_max
            missions_succeeded_max
            missions_mastered_max
            missions_completed_max
          }.each do |attr|
            s.send("#{attr}=", record[attr].to_f.round)
          end
          
          s.mercenaries = MercenaryRelation.count(:joins => :owner, :conditions => ["characters.level = ?", record.level]).to_f / s.total
          s.friends = FriendRelation.count(:joins => :owner, :conditions => ["characters.level = ?", record.level]).to_f / s.total
        end
      end
    end
  end
end
