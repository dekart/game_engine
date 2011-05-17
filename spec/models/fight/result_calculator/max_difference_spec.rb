require 'spec_helper'
require 'models/fight/result_calculator/common'

describe Fight::ResultCalculator::MaxDifference do
  class MaxDifferenceCalculator < Struct.new(:attacker, :victim)
    include Fight::ResultCalculator::MaxDifference
  end

  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      
      @calculator = MaxDifferenceCalculator.new(@attacker, @victim)
    end
    
    it_should_behave_like 'generic fight result calculator'
  end
end