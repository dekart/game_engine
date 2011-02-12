require 'spec_helper'

describe Mission do
  describe '#applicable_payouts' do
    before do
      @mission = Factory(:mission, 
        :payouts => Payouts::Collection.new(DummyPayout.new(:name => 'mission'))
      )
      @mission.mission_group.stub!(:applicable_payouts).and_return(Payouts::Collection.new(DummyPayout.new(:name => 'group')))
    end
    
    it 'should return payout collection' do
      @mission.applicable_payouts.should be_kind_of(Payouts::Collection)
    end
    
    it 'should return payouts from mission and applicable mission group payouts' do
      @mission.applicable_payouts.size.should == 2
      @mission.applicable_payouts.first.name.should == 'mission'
      @mission.applicable_payouts.last.name.should == 'group'
    end
  end
end