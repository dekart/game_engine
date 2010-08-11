class MissionResult
  attr_reader :character, :mission, :rank, :success, :money, :experience, :saved, 
    :payouts, :free_fulfillment, :mission_group, :group_rank, :group_payouts, :loot, :looter

  def self.create(*args)
    new(*args).tap do |result|
      result.save! if result.mission.repeatable? or !result.rank.completed?
    end
  end

  def initialize(character, mission)
    @character  = character
    @mission    = mission
    @mission_group      = mission.mission_group

    @rank = @character.rank_for_mission(@mission)
  end

  def save!
    if valid?
      @success = (rand(100) <= @mission.success_chance)

      Rank.transaction do
        if @success
          mission_money_bonus = 0.01 * @character.assignments.effect_value(:mission_income)

          @money      = (@mission.money * (1 + mission_money_bonus)).ceil
          @experience = mission.experience
          
          calculate_loot

          @rank.win_count += 1
          @rank.save!

          @character.experience += @experience

          @character.charge(- @money, 0, @mission)

          @character.missions_succeeded += 1

          if @rank.just_completed?
            @character.missions_completed += 1
            @character.points += 1

            @payouts = @mission.payouts.apply(@character, :complete)

            @group_rank, @group_payouts = @character.mission_groups.check_completion!(@mission_group)
          else
            @payouts = @mission.payouts.apply(@character,
              @rank.completed? ? :repeat_success : :success
            )
          end
        else
          @payouts = @mission.payouts.apply(@character,
            @rank.completed? ? :repeat_failure : :failure
          )
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
    @requirements_satisfied ||= @mission.requirements.satisfies?(@character)
  end

  def received_something?
    !(@money.nil? && @experience.nil? && @payouts.by_action(:add).empty?)
  end

  def success_text
    texts = @mission.success_text.split(/\n+/)
    texts.reject!{|t| t.blank? }

    texts[(@rank.win_count % texts.size) - 1]
  end

  def calculate_loot
    if @mission.allow_loot? and (rand(100) < @mission.loot_chance)
      if @mission.loot_item_ids.any?
        loot_items = Item.find(@mission.loot_item_ids)
      else
        loot_items = Item.available_for(@character).available_in(:loot).all
      end

      if @loot = loot_items[rand(loot_items.size)]
        @looter = @character.friend_relations.random || @character.mercenary_relations.random

        @character.inventories.give!(@loot)
      end
    end
  end
end