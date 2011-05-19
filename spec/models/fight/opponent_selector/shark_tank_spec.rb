require 'spec_helper'

describe Fight::OpponentSelector::SharkTank do
  class Selector < Struct.new(:attacker)
    include Fight::OpponentSelector::SharkTank
  end
  
  describe '#attacker_tank' do
    
  end

  describe '#can_attack?' do
  end
end