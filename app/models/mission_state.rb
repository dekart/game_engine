class MissionState < ActiveRecord::Base
  belongs_to :character, :autosave => true

  before_save :pack_progress

  def perform!(mission)
    return [:mission_complete] unless mission.tags.include?(:repeatable) or progress_for(mission) < mission.total_steps

    level = level_for(mission)
    requirements = level.requirements(character)

    if requirements.satisfied?
      success = Dice.chance(level.chance)
      reward = level.apply_reward_on(reward_trigger_for(level, success), character)

      if requirements.ep > 0 and free_fulfillment = Dice.chance(character.assignments.mission_energy_effect)
        reward.give_energy(requirements.ep)
      end

      if success
        character.increment(:missions_succeeded)

        progress!(mission)

        if progress_for(level) == level.steps
          character.increment(:missions_completed)

          level.apply_reward_on(:level_complete, character, reward)

          if level.last?
            character.increment(:missions_mastered)

            mission.apply_reward_on(:mission_complete, character, reward)
          end

          if group_complete?(mission.group) and progress_for(mission) == mission.levels.first.steps # should only fire on first levels
            mission.apply_reward_on(:mission_group_complete, character, reward)
          end
        end
      end

      save!

      if success
        [
          :success,
          {
            :reward => reward,
            :free_fulfillment => free_fulfillment
          }
        ]
      else
        [
          :failure,
          {
            :reward => reward,
            :free_fulfillment => free_fulfillment
          }
        ]
      end
    else
      [:unsatisfied_requirements, {:requirements => requirements}]
    end
  end

  def group_complete?(group)
    # Should not be true if some of the missions is not complete yet
    group.missions.each do |mission|
      return false if progress_for(mission) < mission.levels.first.steps
    end

    true
  end

  def reward_trigger_for(level, success = true)
    if progress_for(level) < level.steps
      success ? :success : :failure
    else
      success ? :repeat_success : :repeat_failure
    end
  end

  def progress!(mission, steps = 1)
    if record = progress.assoc(mission.id)
      record[1] += steps
    else
      progress << [mission.id, steps]
    end

    progress.assoc(mission.id)[1]
  end

  def progress
    @progress ||= self[:progress].blank? ? [] : self[:progress].unpack('Q*').in_groups_of(2)
  end

  def current_group
    GameData::MissionGroup[current_group_id]
  end

  def set_current_group(group)
    update_attribute(:current_group_id, group.id)
  end

  def progress_for(level_or_mission)
    case level_or_mission
    when GameData::Mission
      if record = progress.assoc(level_or_mission.id)
        record[1]
      else
        0
      end
    when GameData::MissionLevel
      if record = progress.assoc(level_or_mission.mission.id)
        if level_or_mission.position == 0
          record[1]
        else
          record[1] - level_or_mission.mission.levels[0 .. level_or_mission.position - 1].sum{|l| l.steps }
        end
      else
        0
      end
    end
  end

  def level_for(mission)
    total = progress_for(mission)

    mission.levels.each do |level|
      total -= level.steps

      return level if total < 0
    end

    return mission.levels.last
  end

  protected

  def pack_progress
    self[:progress] = progress.flatten.pack('Q*')
  end
end