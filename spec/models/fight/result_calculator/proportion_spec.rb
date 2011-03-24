require 'spec_helper'
require 'models/fight/result_calculator/common'

describe Fight::ResultCalculator::Proportion do
  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      
      @calculator = Fight::ResultCalculator::Proportion.new(@attacker, @victim)
    end
    
    it_should_behave_like 'generic fight result calculator'
  end
end