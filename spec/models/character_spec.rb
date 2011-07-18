require 'spec_helper'

describe Character do
  describe 'associations' do
    before do
      @character = Character.new
    end
    
    it 'should have many vip money deposits' do
      @character.should have_many(:vip_money_deposits).dependent(:destroy)
    end
    
    it 'should have many vip money withdrawals' do
      @character.should have_many(:vip_money_withdrawals).dependent(:destroy)
    end
  end
  
  describe 'when updating' do
    before do
      @character = Factory(:character)
    end
    
    it 'should assign fight availablity time when health point level is changed' do
      lambda{
        @character.save!
      }.should_not change(@character, :fighting_available_at)
      
      Timecop.freeze(Time.now) do
        @character.hp = 0

        lambda{
          @character.save!
        }.should change(@character, :fighting_available_at).to(5.minutes.from_now)
      end
    end
    
    describe 'when reached enough experience for new level' do
      before do
        @character.experience = 100 # Level 5
      end
      
      it 'should change level to the new value' do
        lambda{
          @character.save
        }.should change(@character, :level).from(1).to(5)
      end
      
      it 'should not change level down if experience table changes' do
        @character.save
        
        lambda{
          @character.experience = 10
          @character.save
        }.should_not change(@character, :level)
      end
      
      it 'should give upgrade points for every reached level' do
        lambda{
          @character.save
        }.should change(@character, :points).by(20)
      end
      
      it 'should give vip money for every reached level' do
        lambda{
          with_setting(:character_vip_money_per_upgrade => 1) do
            @character.save
          end
        }.should change(@character, :vip_money).by(4)
      end
      
      it 'should give incremental vip money bonus for current level' do
        lambda{
          with_setting(:character_vip_money_per_upgrade_per_level => 0.5) do
            @character.save
          end
        }.should change(@character, :vip_money).by(3)
      end
      
      it 'should apply both per-level vip money bonus and incremental bonus' do
        lambda{
          with_setting(:character_vip_money_per_upgrade => 1, :character_vip_money_per_upgrade_per_level => 0.5) do
            @character.save
          end
        }.should change(@character, :vip_money).by(7)
      end
      
      it 'should restore energy points' do
        @character.ep = 0
        
        lambda{
          @character.save
        }.should change(@character, :ep).from(0).to(10)
      end
      
      it 'should restore health points' do
        @character.hp = 0
        
        lambda{
          @character.save
        }.should change(@character, :hp).from(0).to(100)
      end
      
      it 'should restore stamina points' do
        @character.sp = 0
        
        lambda{
          @character.save
        }.should change(@character, :sp).from(0).to(10)
      end
      
      it 'should schedule notification about level up' do
        @character.notifications.should_receive(:schedule).with(:level_up)
        
        @character.save
      end
    end
  end

  
  describe '#weakness_minimum' do
    before do
      @character = Factory(:character, :health => 1000)
    end
    
    it 'should return value from settings when using absolute formula' do
      with_setting(:character_weakness_minimum_formula => 'absolute') do
        @character.weakness_minimum.should == 5
      end
    end
    
    it 'should use absolute formula by default' do
      @character.weakness_minimum.should == 5
    end
    
    it 'should return calculated value when using percentage-based formula' do
      with_setting(:character_weakness_minimum_formula => 'percentage') do
        @character.weakness_minimum.should == 50
      end
    end
  end
end