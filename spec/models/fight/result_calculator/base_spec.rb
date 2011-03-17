require 'spec_helper'

describe Fight::ResultCalculator::Base do
  describe '#initialize' do
    before do
      @attacker = mock('character')
      @victim   = mock('character')
      
      @calculator = Fight::ResultCalculator::Base.new(@attacker, @victim)
    end
    
    it 'should assign attacker' do
      @calculator.attacker.should == @attacker
    end
    
    it 'should assign victim' do
      @calculator.victim.should == @victim
    end
  end
end