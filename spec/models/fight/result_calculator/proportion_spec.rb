require 'spec_helper'
require 'models/fight/result_calculator/common'

describe Fight::ResultCalculator::Proportion do
  class ProportionCalculator < Struct.new(:attacker, :victim)
    include Fight::ResultCalculator::Proportion
  end
  
  describe '#calculate' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      
      @calculator = ProportionCalculator.new(@attacker, @victim)
    end
    
    it_should_behave_like 'generic fight result calculator'
  end
end