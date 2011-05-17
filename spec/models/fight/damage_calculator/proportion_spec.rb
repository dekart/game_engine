require 'spec_helper'

describe Fight::DamageCalculator::Proportion do
  class Calculator < Struct.new(:attacker, :victim)
    include Fight::DamageCalculator::Proportion
  end
  
  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @calculator = Calculator.new(@attacker, @victim)
      @calculator.stub!(:attacker_won?).and_return(true)
    end
    
    it 'should return array with damage values for attacker and victim' do
      result = @calculator.calculate_damage
      
      result.should be_kind_of(Array)
      result.size.should == 2
      result.first.should be_kind_of(Numeric)
      result.last.should be_kind_of(Numeric)
    end
  end
end