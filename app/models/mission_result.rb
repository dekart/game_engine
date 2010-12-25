class MissionResult
  attr_reader :character, :mission, :level, :mission_group,
    :energy, :money, :experience, :loot, :looter, :boost,
    :level_rank, :mission_rank, :group_rank,
    :payouts, :group_payouts

  def self.create(*args)
    new(*args).tap do |r|
      r.save!
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
      MissionLevelRank.transaction do
        # Checking if energy assignment encountered free fulfillment
        if free_fulfillment?
          @energy = 0
        else
          if boost = @character.boosts.best_energy and boost.energy <= @level.energy
            @boost = boost
            
            @energy = (@level.energy - @boost.energy)

            @character.inventories.take!(@boost.item)
          else
            @energy = @level.energy
          end
        end

        @character.ep -= @energy

        if success?
          @experience = @level.experience
          @money      = (@level.money * (1 + @character.assignments.mission_income_effect * 0.01)).ceil

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

  def saved?
    @saved
  end

  def success?
    if @success.nil?
      @success = Dice.chance(@level.chance, 100)
    end

    @success
  end

  def new_record?
    !saved?
  end

  def enough_energy?
    @character.ep >= @level.energy
  end

  def free_fulfillment?
    if @free_fulfillment.nil?
      @free_fulfillment = Dice.chance(@character.assignments.mission_energy_effect, 100)
    end

    @free_fulfillment
  end

  def requirements_satisfied?
    if @requirements_satisfied.nil?
      @requirements_satisfied = @mission.requirements.satisfies?(@character)
    end

    @requirements_satisfied
  end

  def received_something?
    !(@money.nil? && @experience.nil? && @payouts.by_action(:add).empty?)
  end

  protected

  def valid?
    (mission.repeatable? || !@level_rank.completed?) and
    enough_energy? and
    requirements_satisfied?
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
