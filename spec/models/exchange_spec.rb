require 'spec_helper'

describe Exchange do
  describe 'associations' do
    it 'should belong to character' do
      should belong_to :character
    end
    
    it 'should belong to item' do
      should belong_to :item
    end
    
    it 'should have many exchange offers' do
      should have_many :exchange_offers
    end
  end
  
  describe '#validations' do
    before do
      @exchange = Factory(:exchange)
    end
    
    it {should validate_presence_of(:item_id)}
    it {should validate_presence_of(:amount)}
    it {should validate_presence_of(:text)}
    it {should validate_numericality_of(:amount)}
  end
  
  describe 'when creating' do
    it 'should validate amount less or equals then in inventories' do
      character = Factory(:character)
      @exchange = Factory.build(:exchange, :amount => 2, :character => character)
      
      @exchange.should_not be_valid
      @exchange.errors[:amount].should be_present
    end
    
    it 'should validate that item exchangeable' do
      character = Factory(:character)
      item = Factory(:item)
      character.inventories.give!(item)
      
      @exchange = Factory.build(:exchange, :item => item, :character => character)
      
      @exchange.should_not be_valid
      @exchange.errors[:item].should be_present
    end
  end
  
  describe 'when saving' do
    before do
      @exchange = Factory.build(:exchange)
    end
    
    it 'should be valid' do
      @exchange.save
      
      @exchange.should be_valid
    end
  end
  
  describe '#methods' do
    before do
      @exchange = Factory(:exchange)
      @character = @exchange.character
    end
    
    it 'should return inventory' do
      @exchange.inventory.should == @character.inventories.first
    end
    
    it 'should return payout' do
      payout = Payouts::Item.new(:value => @exchange.item, :amount => @exchange.amount)
      
      payout.item.should == @exchange.payout.item
      payout.amount.should == @exchange.payout.amount
    end
    
    it 'should return key' do
      @exchange.key.should_not be_empty
    end
  end
  
  describe 'states' do
    before do
      @exchange = Factory(:exchange)
    end
    
    describe '#created' do
      it 'should be in created state' do
        @exchange.created?.should be_true
      end
    end
    
    describe '#transacted' do
      before do
        @exchange_offer = Factory(:exchange_offer, :exchange => @exchange)
      end
      
      it 'should raise exception when transacted without exchange offer' do
        lambda {
          @exchange.transact!
        }.should raise_exception(ArgumentError)
      end
      
      it 'should fire with exchange offer' do
        lambda {
          @exchange.transact!(@exchange_offer)
        }.should change(@exchange, :state).from('created').to('transacted')
      end
      
      it 'should accept choosed exchange offer when transacted' do
        lambda {
          @exchange.transact!(@exchange_offer)
        }.should change{ @exchange_offer.reload.state }.from('created').to('accepted')
      end
      
      it 'should decline not choosed exchange offers' do
        @other_exchange_offer = Factory(:exchange_offer, :exchange => @exchange)
        
        lambda {
          @exchange.transact!(@exchange_offer)
        }.should change(ExchangeOffer, :count).by(-1)
      end
    end
    
    describe '#invalidated' do
      it 'should invalidate exchange if inventory was destroyed' do
        lambda {
          @exchange.inventory.destroy
        }.should change{@exchange.reload.state}.from('created').to('invalid')
      end
      
      it 'should invalidate exchange if inventory amount is not enough' do
        @exchange.character.inventories.give!(@exchange.item)
        @exchange.update_attribute(:amount, 2)
        
        lambda {
          @exchange.character.inventories.take!(@exchange.item)
        }.should change{@exchange.reload.state}.from('created').to('invalid')
      end
    end
  end
end