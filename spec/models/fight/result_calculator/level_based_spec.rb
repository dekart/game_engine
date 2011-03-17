require 'spec_helper'

describe Fight::ResultCalculator::LevelBased do
  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      
      @calculator = Fight::ResultCalculator::LevelBased.new(@attacker, @victim)
    end
    
    it 'should return true or false' do
      [true, false].should include(@calculator.calculate)
    end
  end
end