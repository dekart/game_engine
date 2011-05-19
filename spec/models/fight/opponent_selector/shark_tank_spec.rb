require 'spec_helper'

describe Fight::OpponentSelector::SharkTank do
  class SharkTankSelector < Struct.new(:attacker, :victim)
    include Fight::OpponentSelector::SharkTank
  end
  
  describe '#attacker_level_range' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)

      @selector = SharkTankSelector.new(@attacker, @victim)
    end

    [1, 2, 3, 4, 5, 7, 11, 20, 30, 75, 120].each do |level|
      describe "on level #{level}" do
        before do
          @attacker.level = level
        end
        
        it "should return level range for level #{level}" do
          @selector.attacker_level_range.should be_kind_of(Range)
        end
      
        it 'should return range that includes attacker level' do
          @selector.attacker_level_range.should include(level)
        end
      end
    end
  end

  describe '#can_attack?' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      @victim.level = 5

      @selector = SharkTankSelector.new(@attacker, @victim)
    end
    
    it 'should return true when victim is in attacker\'s level range' do
      @selector.stub!(:attacker_level_range).and_return 1..5
      
      @selector.can_attack?.should be_true
    end
    
    it 'should return false if victim is not in attacker\'s level range' do
      @selector.stub!(:attacker_level_range).and_return 6..10
      
      @selector.can_attack?.should_not be_true
    end
  end
  
  describe '#opponents' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character, :level => 10)
      
      @selector = SharkTankSelector.new(@attacker)
    end
    
    it 'should include opponents from attacker\'s level range' do
      @selector.stub!(:attacker_level_range).and_return(10..10)
      
      @selector.opponents.should include(@victim)
    end
    
    it 'should not include opponents from levels below attacker\'s lowest level' do
      @selector.stub!(:attacker_level_range).and_return(11..15)
      
      @selector.opponents.should_not include(@victim)
    end
    
    it 'should not include opponents from levels above attacker\'s highest level' do
      @selector.stub!(:attacker_level_range).and_return(1..9)
      
      @selector.opponents.should_not include(@victim)
    end
  end
end