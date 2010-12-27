require "spec_helper"

describe Character do
  describe "when receiving mission level rank" do
    before do
      @character = Factory(:character)

      @mission = Factory(:mission)

      @level1 = Factory(:mission_level, :mission => @mission)
      @level2 = Factory(:mission_level, :mission => @mission)
    end

    it 'should return first incomplete level rank' do
      @rank = @character.mission_level_ranks.create!(
        :level => @level1,
        :progress => 1
      )
      
      @character.mission_levels.rank_for(@mission).should == @rank
    end

    it 'should return rank for latest level when mission is completed' do
      @rank1 = @character.mission_level_ranks.create!(
        :level => @level1,
        :progress => 5
      )
      @rank2 = @character.mission_level_ranks.create!(
        :level => @level2,
        :progress => 5
      )

      @character.missions.check_completion!(@mission)

      @character.mission_levels.rank_for(@mission).should == @rank2
    end

    it 'should instantiate rank for the first incomplete mission level' do
      @rank1 = @character.mission_level_ranks.create!(
        :level => @level1,
        :progress => 5
      )
      
      @new_rank = @character.mission_levels.rank_for(@mission)

      @new_rank.should be_new_record
      @new_rank.level.should == @level2
      @new_rank.character.should == @character
    end
  end

  describe 'when fetching a list of completed missions in a group' do
    before do
      @group = Factory(:mission_group)

      @mission1 = Factory(:mission_with_level, :mission_group => @group)
      @mission2 = Factory(:mission_with_level, :mission_group => @group)

      @other_group = Factory(:mission_group)

      @mission3 = Factory(:mission_with_level, :mission_group => @other_group)

      @character = Factory(:character)
    end

    it 'should return empty array when there is no completed missions' do
      @character.missions.completed_ids(@group).should == []
    end

    describe 'when there are completed missions' do
      def complete_mission!(mission)
        MissionLevelRank.create(
          :level      => mission.levels.first,
          :character  => @character,
          :progress   => mission.levels.first.win_amount
        )
        @character.missions.check_completion!(mission)
      end

      it 'should return ID of only completed missions' do
        complete_mission!(@mission1)

        @character.missions.completed_ids(@group).should == [@mission1.id]
      end

      it 'should not return IDs of completed missions from other groups' do
        complete_mission!(@mission1)
        complete_mission!(@mission3)

        @character.missions.completed_ids(@group).should == [@mission1.id]
        @character.missions.completed_ids(@other_group).should == [@mission3.id]
      end
    end
  end
end