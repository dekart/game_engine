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
    
    it 'should not include victims defeated less than 1 hour ago' do
      Fight.create!(:attacker => @attacker, :victim => @victim)
      
      Fight.last.update_attribute(:winner_id, @victim.id)      
            
      @selector.opponents.should include(@victim)
      
      Fight.last.update_attribute(:winner_id, @attacker.id)
      
      @selector.opponents.should_not include(@victim)
      
      Fight.last.update_attribute(:created_at, 61.minute.ago)
      
      @selector.opponents.should include(@victim)
    end
    
    it 'should not include alliance members to the list (if configured that way)' do
      @attacker.friend_relations.establish!(@victim)

      @selector.opponents.should include(@victim)

      with_setting(:fight_alliance_attack => false) do
        @selector.opponents.should_not include(@victim)
      end
    end
    
    it 'should not include attacker to the list' do
      @selector.opponents.should_not include(@attacker)
    end
    
    it 'should not include weak opponents if configured that way' do
      @selector.opponents.should include(@victim)
      
      @victim.hp = 0
      @victim.save!
            
      @selector.opponents.should include(@victim)
      
      with_setting(:fight_weak_opponents => false) do
        @selector.opponents.should_not include(@victim)
      end
    end
    
    it 'should limit list to 10 opponents' do
      10.times do
        Factory(:character)
      end
      
      @selector.opponents.size.should == 10
    end
    
    it 'should randomize opponents' do
      10.times do
        Factory(:character)
      end
      
      @selector.opponents.should_not == @selector.opponents
    end
  end
end