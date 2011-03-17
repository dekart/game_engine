require 'spec_helper'

describe Fight::ResultCalculator::MaxDifference do
  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      
      @calculator = Fight::ResultCalculator::MaxDifference.new(@attacker, @victim)
    end
    
    it 'should return true or false' do
      [true, false].should include(@calculator.calculate)
    end
  end
end