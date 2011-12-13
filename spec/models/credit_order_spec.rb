require 'spec_helper'

describe CreditOrder do
  describe 'associations' do
    before do
      @order = CreditOrder.new
    end
    
    it 'should belong to character' do
      @order.should belong_to(:character)
    end

    it 'should belong to package' do
      @order.should belong_to(:package)
    end
  end
  
  
  describe 'states' do
    before do
      @order = Factory(:credit_order)
    end
    
    describe 'when previewed' do
      it 'should be placeable' do
        @order.can_place?.should be_true
      end
    end
    
    describe 'when placed' do
      before do
        @order.update_attribute(:state, 'placed')
      end
      
      it 'should be settleable' do
        @order.can_settle?.should be_true
      end
      
      it 'should be cancelable' do
        @order.can_cancel?.should be_true
      end
    end
    
    describe 'when settled' do
      before do
        @order.update_attribute(:state, 'settled')
      end
      
      it 'should be disputable' do
        @order.can_dispute?.should be_true
      end
      
      it 'should be refundable' do
        @order.can_refund?.should be_true
      end
    end
    
    describe 'when disputed' do
      before do
        @order.update_attribute(:state, 'disputed')
      end
      
      it 'should be settleable' do
        @order.can_settle?.should be_true
      end
      
      it 'should be refundable' do
        @order.can_refund?.should be_true
      end
    end
  end
  
  
  describe '#create' do
    before do
      @order = Factory.build(:credit_order)
    end
    
    %w{facebook_id character package}.each do |attr|
      it "should validate presence of #{attr}" do
        @order.should validate_presence_of(attr)
      end
    end
    
    it 'should validate uniqueness of facebook_id' do
      @other_order = Factory(:credit_order)
      
      @order.should validate_uniqueness_of(:facebook_id)
    end
  end
  
  
  describe '#place' do
    before do
      @character = Factory(:character, :vip_money => 50)
      @order = Factory(:credit_order, :character => @character, :state => 'previewed')
    end
    
    it 'should add vip money to character if the order was previewed previously' do
      lambda{
        @order.place
      }.should change(@character, :vip_money).by(10)
      
      @character.vip_money_deposits.should_not be_empty
      @character.vip_money_deposits.last.reference.should == 'credits'
    end
    
    it 'should not add vip money to character if the order was disputed previously' do
      @order.update_attribute(:state, 'disputed')
      
      lambda{
        @order.place
      }.should_not change(@character, :vip_money)
    end
  end
end