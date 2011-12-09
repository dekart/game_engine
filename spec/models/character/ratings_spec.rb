require "spec_helper"

describe Character::Ratings do
  
  describe 'total score' do
    def with_reset_total_score_settings(values = {}, &block)
      values.reverse_merge!({
        :total_score_fights_won_factor => 0, 
        :total_score_killed_monsters_count_factor => 0,
        :total_score_total_monsters_damage_factor => 0, 
        :total_score_total_money_factor => 0,
        :total_score_missions_succeeded_factor => 0, 
        :total_score_level_factor => 0
      })
      
      with_setting(values, &block)
    end
    
    before do
      @character = Factory(:character)
    end
    
    it 'should be 0' do
      with_reset_total_score_settings do
        @character.total_score.should == 0
      end
    end
    
    it 'should updates after changing score, which touches total score with factor 1' do
      with_reset_total_score_settings(:total_score_level_factor => 1) do
        lambda{
          @character.level += 1
        }.should change(@character, :total_score).by(1)
      end
    end
    
    it "should updates after changing score, which touches total score with factor 3.5" do
      with_reset_total_score_settings(:total_score_level_factor => 3.5) do
        @character = Factory(:character)
        
        lambda{
          @character.level += 1
        }.should change(@character, :total_score).by(3)
      end
    end
    
    it "should updates after changing scores, which touches total score with several factors" do
      with_reset_total_score_settings(:total_score_level_factor => 10, :total_score_fights_won_factor => 3) do
        @character = Factory(:character)
        
        lambda{
          @character.level += 1
          @character.fights_won += 1
        }.should change(@character, :total_score).by(13)
      end
    end
    
    it "should not updates after changing score, which doen't touches total score" do
      with_reset_total_score_settings(:total_score_level_factor => 1) do
        lambda{
          @character.fights_won += 1
        }.should_not change(@character, :total_score)
      end
    end
  end
end