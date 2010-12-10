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

      @mission_rank = @character.mission_ranks.create!(:mission => @mission)

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
end