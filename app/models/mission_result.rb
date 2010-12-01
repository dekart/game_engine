class MissionResult
  attr_reader :character, :mission, :level, :mission_group,
    :money, :experience, :loot, :looter,
    :success, :free_fulfillment, :saved,
    :level_rank, :mission_rank, :group_rank,
    :payouts, :group_payouts

  def self.create(*args)
    new(*args).tap do |result|
      result.save! if result.mission.repeatable? or !result.level_rank.completed?
    end
  end

  def initialize(character, mission)
    @character      = character
    @mission        = mission
    @mission_group  = mission.mission_group

    @level_rank   = character.mission_levels.rank_for(@mission)
    @level        = @level_rank.level
  end

  def save!
    if valid?
      @success = (rand(100) <= @level.chance)

      MissionLevelRank.transaction do
        # Checking if energy assignment encountered free fulfillment
        @free_fulfillment = (@character.assignments.effect_value(:mission_energy) > rand(100))

        @character.ep -= @level.energy unless @free_fulfillment

        if @success
          money_bonus = 0.01 * @character.assignments.effect_value(:mission_income)

          @money      = (@level.money * (1 + money_bonus)).ceil
          @experience = @level.experience

          calculate_loot

          @level_rank.progress += 1
          @level_rank.save!

          @character.experience += @experience

          @character.charge(- @money, 0, @mission)

          @character.missions_succeeded += 1

          if @level_rank.just_completed?
            @character.missions_completed += 1
            @character.missions_mastered  += 1 if @level.last?

            @character.points += 1

            @payouts = @level.payouts.apply(@character, :complete, @mission)

            @mission_rank = @character.missions.check_completion!(@mission)

            @group_rank, @group_payouts = @character.mission_groups.check_completion!(@mission_group)

            @character.news.add(:mission_complete,
              :mission_id     => @mission.id,
              :level_rank_id  => @level_rank.id
            )
          else
            payout_trigger = @level_rank.completed? ? :repeat_success : :success

            @payouts = @level.payouts.apply(@character, payout_trigger, @mission)
          end
        else
          payout_trigger = @level_rank.completed? ? :repeat_failure : :failure

          @payouts = @level.payouts.apply(@character, payout_trigger, @mission)
        end

        @character.save!
      end

      @saved = true
    end
  end

  def valid?
    enough_energy? &&
    (mission.repeatable? || !@level_rank.completed?) &&
    requirements_satisfied?
  end

  def new_record?
    !saved
  end

  def enough_energy?
    @character.ep >= @level.energy
  end

  def requirements_satisfied?
    @requirements_satisfied ||= @mission.requirements.satisfies?(@character)
  end

  def received_something?
    !(@money.nil? && @experience.nil? && @payouts.by_action(:add).empty?)
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
