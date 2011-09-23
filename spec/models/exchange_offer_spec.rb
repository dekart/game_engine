require 'spec_helper'

describe ExchangeOffer do
  describe 'associations' do
    it 'should belong to character' do
      should belong_to :character
    end
    
    it 'should belong to item' do
      should belong_to :item
    end
    
    it 'should has many exchange offers' do
      should belong_to :exchange
    end
  end
  
  describe 'when creating' do
    before do
      @exchange_offer = Factory.build(:exchange_offer)
    end
    
    %w{exchange_id item_id character_id amount}.each do |attribute|
      it "should validate presence of #{attribute}" do
        @exchange_offer.should validate_presence_of(attribute)
      end
    end
    
    it "should validate numericality of amount" do
      @exchange_offer.should validate_numericality_of(:amount)
    end
    
    it 'should validate amount less or equals then in inventories' do
      character = Factory(:character)
      @exchange_offer = Factory.build(:exchange_offer, :amount => 2, :character => character)
      
      @exchange_offer.should_not be_valid
      @exchange_offer.errors.on(:amount).should be_present
    end
    
    it 'should validate that item exchangeable' do
      character = Factory(:character)
      item = Factory(:item)
      character.inventories.give!(item)
      
      @exchange_offer = Factory.build(:exchange_offer, :item => item, :character => character)
      
      @exchange_offer.should_not be_valid
      @exchange_offer.errors.on(:item).should be_present
    end
  end
  
  describe 'when saving' do
    before do
      @exchange_offer = Factory.build(:exchange_offer)
    end
    
    it 'should be valid' do
      @exchange_offer.save
      
      @exchange_offer.should be_valid
    end
    
    it 'should create notification to exchanger' do
      @exchange_offer.save
      
      notification = @exchange_offer.exchange.character.notifications.first
      
      notification.class.should == Notification::ExchangeOfferCreated
      notification.exchange_offer.should == @exchange_offer
    end
  end
  
  describe 'scopes' do
    before do
      @exchange_offer = Factory(:exchange_offer)
      @exchange = @exchange_offer.exchange
    end
    
    it 'should return exchange offers created by character' do
      @exchange.exchange_offers.created_by(@exchange_offer.character).should include(@exchange_offer)
    end
  end
  
  describe '#methods' do
    before do
      @exchange_offer = Factory(:exchange_offer)
      @character = @exchange_offer.character
    end
    
    it 'should return inventory' do
      @exchange_offer.inventory.should == @character.inventories.first
    end
    
    it 'should return payout' do
      payout = Payouts::Item.new(:value => @exchange_offer.item, :amount => @exchange_offer.amount)
      
      payout.item.should == @exchange_offer.payout.item
      payout.amount.should == @exchange_offer.payout.amount
    end
  end
  
  describe 'states' do
    before do
      @exchange_offer = Factory(:exchange_offer)
      @exchange = @exchange_offer.exchange
    end
    
    describe '#created' do
      it 'should be in created state' do
        @exchange.created?.should be_true
      end
    end
    
    describe '#accepted' do
      it 'should fire' do
        lambda {
          @exchange_offer.accept!
        }.should change(@exchange_offer, :state).from('created').to('accepted')
      end
      
      it 'should send notification' do
        @exchange_offer.accept!
        
        @exchange_offer.character.notifications.first.class.should == Notification::ExchangeOfferAccepted
      end
      
      it 'should make items transfer' do
        @exchange_offer.accept!
        
        @exchange_offer.character.items.should include(@exchange.item)
        @exchange.character.items.should include(@exchange_offer.item)
      end
      
      it 'should make transfer with amount' do
        @exchange_offer.character.inventories.give!(@exchange_offer.item)
        @exchange_offer.update_attributes!(:amount => 2)
        
        @exchange.character.inventories.give!(@exchange.item, 2)
        @exchange.update_attributes!(:amount => 3)
        
        @exchange_offer.accept!
        
        @exchange_offer.character.inventories.find_by_item_id(@exchange.item).amount.should == 3
        
        @exchange.character.inventories.find_by_item_id(@exchange_offer.item).amount.should == 2
      end
      
      it 'should not transact if exchange creator doesnt have item in inventory' do
        @exchange.character.inventories.take!(@exchange.item)
        
        lambda {
          @exchange_offer.accept!
        }.should raise_exception(StateMachine::InvalidTransition)
        
        @exchange.errors.on(:amount).should be_present
      end
      
      it 'should not transact if exchange offer creator doesnt have item in inventory' do
        @exchange_offer.character.inventories.take!(@exchange_offer.item)
        
        lambda {
          @exchange_offer.accept!
        }.should raise_exception(StateMachine::InvalidTransition)
        
        @exchange_offer.errors.on(:amount).should be_present
      end
    end
  end
  
  describe 'when inventory changed' do
    before do
      @exchange_offer = Factory(:exchange_offer)
      @exchange = @exchange_offer.exchange
    end
    
    it 'should destroy exchange offer if inventory destroyed and offer is not accepted' do
      lambda {
        @exchange_offer.inventory.destroy
      }.should change(ExchangeOffer, :count).by(-1)
    end
    
    it 'should destroy exchange offer if inventory amount changed and offer is not accepted' do
      @exchange_offer.character.inventories.give!(@exchange_offer.item)
      @exchange_offer.update_attribute(:amount, 2)
      
      lambda {
        @exchange_offer.character.inventories.take!(@exchange_offer.item)
      }.should change(ExchangeOffer, :count).by(-1)
    end
    
    it 'should not destroy exchange offer if is accepted' do
      @exchange.transact!(@exchange_offer)
      @exchange_offer.character.reload.inventories.give!(@exchange_offer.item)
      
      lambda {
        @exchange_offer.character.reload.inventories.take!(@exchange_offer.item)
      }.should_not change(ExchangeOffer, :count)
    end
  end
end