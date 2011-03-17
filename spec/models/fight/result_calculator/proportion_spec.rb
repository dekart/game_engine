require 'spec_helper'

describe Fight::ResultCalculator::Proportion do
  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      
      @calculator = Fight::ResultCalculator::Proportion.new(@attacker, @victim)
    end
    
    it 'should return true or false' do
      [true, false].should include(@calculator.calculate)
    end
  end
end