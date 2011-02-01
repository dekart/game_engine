require 'spec_helper'

describe Fight do
  describe 'when creating' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      @fight = Fight.new(:attacker => @attacker, :victim => @victim)
    end
    
    it 'should give an error when attacker doesn\'t have enough stamina'
    
    it 'should give an error when victim is too weak (if configured that way)' do
      @victim.hp = 0
      @victim.save!
      
      @fight.should be_valid
      
      with_setting(:fight_weak_opponents, false) do
        @fight.should_not be_valid
        @fight.errors.on(:victim).should =~ /too weak/
      end
    end
    
    it 'should give an error when attacking alliance member if configured that way'
    it 'should give an error when attacker is weak'
    it 'should give an error when trying to attack yourself'
    it 'should give an error when trying to respond to fight that is not respondable'
    it 'should give an error when trying to attack a victim that attacker cannot attack'
    
    it 'should be successfully created' do
      @fight.save.should be_true
    end
  end
end