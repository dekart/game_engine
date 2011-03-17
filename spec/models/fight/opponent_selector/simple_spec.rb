require 'spec_helper'

describe Fight::OpponentSelector::Simple do
  describe '#can_attack?' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @selector = Fight::OpponentSelector::Simple.new(@attacker)
    end
    
    it 'should return false if victim level is lower than attacker level' do
      @attacker.level = 2
      
      @selector.can_attack?(@victim).should be_false
    end
    
    it 'should return false if victim level is more than 5 levels higher than attacker level' do
      @victim.level = 7
      
      @selector.can_attack?(@victim).should be_false
    end
    
    it 'should return false if defeated this opponent less than 1 hour ago' do
      Fight.create!(:attacker => @attacker, :victim => @victim)
      
      Fight.last.update_attribute(:winner_id, @victim.id)      
            
      @selector.can_attack?(@victim).should be_true
      
      Fight.last.update_attribute(:winner_id, @attacker.id)
      
      @selector.can_attack?(@victim).should be_false

      Fight.last.update_attribute(:created_at, 61.minute.ago)

      @selector.can_attack?(@victim).should be_true
    end
    
    it 'should return false when attacking alliance member (if configured that way)' do
      @attacker.friend_relations.establish!(@victim)
      
      @selector.can_attack?(@victim).should be_true
      
      with_setting(:fight_alliance_attack => false) do
        @selector.can_attack?(@victim).should be_false
      end
    end
    
    it 'should return false when attacking weak opponent (if configured that way)' do
      @victim.hp = 0
      @victim.save!
      
      @selector.can_attack?(@victim).should be_true
      
      with_setting(:fight_weak_opponents => false) do
        @selector.can_attack?(@victim).should be_false
      end
    end
    
    it 'should return true if all requirements are met' do
      @selector.can_attack?(@victim).should be_true
    end
  end
  
  describe '#list' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @selector = Fight::OpponentSelector::Simple.new(@attacker)
    end
    
    it 'should not include opponents from levels below attacker' do
      @selector.victims.should include(@victim)

      @attacker.level = 2
      
      @selector.victims.should_not include(@victim)
    end
    
    it 'should not include opponents from more than 5 levels above attacker' do
      @selector.victims.should include(@victim)

      @victim.update_attribute(:level, 7)

      @selector.victims.should_not include(@victim)
    end
    
    it 'should not include victims defeated less than 1 hour ago' do
      Fight.create!(:attacker => @attacker, :victim => @victim)
      
      Fight.last.update_attribute(:winner_id, @victim.id)      
            
      @selector.victims.should include(@victim)
      
      Fight.last.update_attribute(:winner_id, @attacker.id)
      
      @selector.victims.should_not include(@victim)
      
      Fight.last.update_attribute(:created_at, 61.minute.ago)
      
      @selector.victims.should include(@victim)
    end
    
    it 'should not include alliance members to the list (if configured that way)' do
      @attacker.friend_relations.establish!(@victim)

      @selector.victims.should include(@victim)

      with_setting(:fight_alliance_attack => false) do
        @selector.victims.should_not include(@victim)
      end
    end
    
    it 'should not include attacker to the list' do
      @selector.victims.should_not include(@attacker)
    end
    
    it 'should not include weak opponents if configured that way' do
      @selector.victims.should include(@victim)
      
      @victim.hp = 0
      @victim.save!
            
      @selector.victims.should include(@victim)
      
      with_setting(:fight_weak_opponents => false) do
        @selector.victims.should_not include(@victim)
      end
    end
    
    it 'should limit list to 10 opponents' do
      10.times do
        Factory(:character)
      end
      
      @selector.victims.size.should == 10
    end
    
    it 'should randomize opponents' do
      10.times do
        Factory(:character)
      end
      
      @selector.victims.should_not == @selector.victims
    end
  end
end