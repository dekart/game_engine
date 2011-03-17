require 'spec_helper'

describe Fight::DamageCalculator::Proportion do
  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @calculator = Fight::DamageCalculator::Proportion.new(@attacker, @victim, @attacker)
    end
    
    it 'should return array with damage values for attacker and victim' do
      result = @calculator.calculate
      
      result.should be_kind_of(Array)
      result.size.should == 2
      result.first.should be_kind_of(Numeric)
      result.last.should be_kind_of(Numeric)
    end
  end
end