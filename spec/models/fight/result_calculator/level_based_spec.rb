require 'spec_helper'
require 'models/fight/result_calculator/common'

describe Fight::ResultCalculator::LevelBased do
  class LevelBasedCalculator < Struct.new(:attacker, :victim)
    include Fight::ResultCalculator::LevelBased
  end

  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      
      @calculator = LevelBasedCalculator.new(@attacker, @victim)
    end
    
    it_should_behave_like 'generic fight result calculator'
  end
end