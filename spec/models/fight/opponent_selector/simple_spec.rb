require 'spec_helper'

describe Fight::OpponentSelector::Simple do
  class SimpleSelector < Struct.new(:attacker, :victim)
    include Fight::OpponentSelector::Simple
  end
  

  describe '#can_attack?' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @selector = SimpleSelector.new(@attacker, @victim)
    end
    
    it 'should return false if victim level is lower than attacker level' do
      @attacker.level = 2
      
      @selector.can_attack?.should be_false
    end
    
    it 'should return false if victim level is more than 5 levels higher than attacker level' do
      @victim.level = 7
      
      @selector.can_attack?.should be_false
    end
  end
  
  
  describe '#opponents' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @selector = SimpleSelector.new(@attacker)
    end

    it 'should not include opponents from levels below attacker' do
      @selector.opponents.should include(@victim)

      @attacker.level = 2
      
      @selector.opponents.should_not include(@victim)
    end
    
    it 'should not include opponents from more than 5 levels above attacker' do
      @selector.opponents.should include(@victim)

      @victim.update_attribute(:level, 7)

      @selector.opponents.should_not include(@victim)
    end
  end
end