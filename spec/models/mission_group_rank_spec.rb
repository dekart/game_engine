require 'spec_helper'

describe MissionGroupRank do
  describe 'when checking if mission group is completed' do
    before do
      @group = Factory(:mission_group)

      @mission1 = Factory(:mission_with_level, :mission_group => @group)
      @mission2 = Factory(:mission_with_level, :mission_group => @group)

      @other_group = Factory(:mission_group)

      @mission3 = Factory(:mission_with_level, :mission_group => @other_group)

      @character = Factory(:character)

      @rank = MissionGroupRank.new(
        :character => @character,
        :mission_group => @group
      )
    end

    def complete_mission!(mission)
      MissionLevelRank.create(
        :level      => mission.levels.first,
        :character  => @character,
        :progress   => mission.levels.first.win_amount
      )
      @character.missions.check_completion!(mission)
    end

    it 'should return true if cached to attribute' do
      MissionGroupRank.create!(
        :character => @character,
        :mission_group => @group
      )

      MissionGroupRank.update_all :completed => true

      MissionGroupRank.first.should be_completed
    end
  end
end