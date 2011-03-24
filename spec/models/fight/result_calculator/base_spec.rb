require 'spec_helper'
require 'models/fight/result_calculator/common'

describe Fight::ResultCalculator::Base do
  describe '#initialize' do
    before do
      @attacker = mock('character')
      @victim   = mock('character')
      
      @calculator = Fight::ResultCalculator::Base.new(@attacker, @victim)
    end
    
    it_should_behave_like 'generic fight result calculator'
  end
end