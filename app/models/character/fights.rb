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

        after_create  :update_opponent_bucket
        before_save   :update_fight_availability_time, :if => :hp_changed?
        before_save   :update_excluded_from_fights_at, :if => :exclude_from_fights_changed?
      end
    end

    def fight_requirements
      @requirements ||= Requirements::Collection.new(
        weakness_requirement,
        Requirements::StaminaPoint.new(:value => Setting.i(:fight_stamina_required))
      )
    end

    def update_fight_optout!(optout)
      if optout
        self.exclude_from_fights = true
      elsif time_to_fight_optin <= 0
        self.exclude_from_fights = false
      end

      save
    end

    def time_to_fight_optin
      Setting.i(:fight_optout_minimum_timeframe).days.since(excluded_from_fights_at) - Time.now
    end

    protected

    def update_fight_availability_time
      if !Setting.b(:fight_weak_opponents) && weak?
        Fight::OpponentBuckets.delete(self) # Removing player from opponent list

        self.fighting_available_at = hp_restore_time(weakness_minimum).seconds.from_now
      end

      true
    end

    def update_opponent_bucket
      Fight::OpponentBuckets.update(self)

      true
    end

    def update_excluded_from_fights_at
      self.excluded_from_fights_at = exclude_from_fights ? Time.now : Time.at(0)
    end
  end
end