class MissionResult
  attr_reader :character, :mission, :rank, :success, :money, :experience, :saved, :payouts, :free_fulfillment

  def self.create(*args)
    result = self.new(*args)

    result.save! if result.mission.repeatable? or !result.rank.completed?
    
    return result
  end

  def initialize(character, mission)
    @character  = character
    @mission    = mission

    @rank = @character.rank_for_mission(@mission)
  end

  def save!
    if @character.can_fulfill?(@mission)
      @success = (rand(100) <= @mission.success_chance)

      Rank.transaction do
        if @success
          mission_money_bonus = 0.01 * @character.assignments.effect_value(:mission_income)

          @money      = (@mission.money * (1 + mission_money_bonus)).ceil
          @experience = self.mission.experience

          @rank.win_count += 1
          @rank.save!

          @character.basic_money += @money
          @character.experience += @experience

          @character.missions_succeeded += 1

          if @rank.just_completed?
            @character.missions_completed += 1
            @character.points += 1
            @character.vip_money += 1
            
            @payouts = @mission.payouts.apply(@character, :complete)
          else
            @payouts = @mission.payouts.apply(@character, :success)
          end
        else
          @payouts = @mission.payouts.apply(@character, :failure)
        end

        # Checking if energy assignment encountered free fulfillment
        @free_fulfillment = (@character.assignments.effect_value(:mission_energy) > rand(100))

        @character.ep -= @mission.ep_cost unless @free_fulfillment
        
        @character.save!
      end

      @saved = true
    end
  end

  def valid?
    enough_energy? and (mission.repeatable? or !rank.completed?) and requirements_satisfied?
  end

  def new_record?
    !saved
  end

  def enough_energy?
    @character.ep >= @mission.ep_cost
  end

  def requirements_satisfied?
    @mission.requirements.satisfies?(@character)
  end

  def received_something?
    !(@money.nil? && @experience.nil? && @payouts.by_action(:received).empty?)
  end

  def success_text
    texts = @mission.success_text.split(/\n+/)
    texts.reject!{|t| t.blank? }

    texts[(@rank.win_count % texts.size) - 1]
  end
end