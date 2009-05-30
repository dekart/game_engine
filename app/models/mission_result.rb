class MissionResult
  attr_reader :character, :mission, :rank, :success, :money, :experience, :saved, :payouts, :free_fulfillment

  def self.create(*args)
    result = self.new(*args)

    result.save! unless result.rank.completed?
    
    return result
  end

  def initialize(character, mission)
    @character  = character
    @mission    = mission

    @rank = @character.rank_for_mission(@mission)
  end

  def save!
    if enough_energy?
      @success = (rand(100) <= @mission.success_chance)

      Rank.transaction do
        if @success
          @money      = rand(@mission.money_max - @mission.money_min) + @mission.money_min
          @experience = self.mission.experience

          @rank.increment(:win_count)
          @rank.save!

          @character.increment(:basic_money, @money)
          @character.increment(:experience, @experience)

          @character.increment(:missions_succeeded)

          if @rank.completed?
            @character.increment(:missions_completed)
            
            @payouts = @mission.payouts.apply(@character, :complete)
          else
            @payouts = @mission.payouts.apply(@character, :success)
          end
        else
          @payouts = @mission.payouts.apply(@character, :failure)
        end

        # Checking if energy assignment encountered free fulfillment
        @free_fulfillment = (@character.assignments.effect_value(:mission_energy) > rand(100))

        unless @free_fulfillment
          @character.ep -= @mission.ep_cost
        end
        
        @character.save!
      end

      @saved = true
    end
  end

  def enough_energy?
    @character.ep >= @mission.ep_cost
  end

  def received_something?
    !(@money.nil? && @experience.nil? && @payouts.by_action(:received).empty?)
  end
end