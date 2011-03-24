require 'spec_helper'
require 'models/fight/result_calculator/common'

describe Fight::ResultCalculator::MaxDifference do
  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      
      @calculator = Fight::ResultCalculator::MaxDifference.new(@attacker, @victim)
    end
    
    it_should_behave_like 'generic fight result calculator'
  end
end