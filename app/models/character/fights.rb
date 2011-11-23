class Character
  module Fights
    def self.included(base)
      base.class_eval do
        has_many :attacks,
          :class_name   => "Fight",
          :foreign_key  => :attacker_id,
          :dependent    => :delete_all
        has_many :defences,
          :class_name   => "Fight",
          :foreign_key  => :victim_id,
          :dependent    => :delete_all
        has_many :won_fights,
          :class_name   => "Fight",
          :foreign_key  => :winner_id

        before_save :update_fight_availability_time, :if => :hp_changed?
      end
    end
    
    def fight_requirements
      @requirements ||= Requirements::Collection.new(
        weakness_requirement,
        Requirements::StaminaPoint.new(:value => Setting.i(:fight_stamina_required))
      )
    end
    
    protected

    def update_fight_availability_time
      if !Setting.b(:fight_weak_opponents) && weak? 
        Fight::OpponentBuckets.delete_id(id) # Removing player from opponent list
        
        self.fighting_available_at = hp_restore_time(weakness_minimum).seconds.from_now
      end
    end
  end
end