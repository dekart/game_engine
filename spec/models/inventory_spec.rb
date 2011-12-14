require 'spec_helper'

describe Inventory do
  before :each do
    @character = Factory(:character)
    @item = Factory(:item)
    @inventory = @character.inventories.create!(:item => @item, :amount => 1)
  end

  it "should delegate payouts to item" do
    @inventory.payouts.should === @item.payouts
  end
  
  describe '#save' do
    before do
      @inventory = Factory(:inventory)
    end
    
    it 'should validate that inventory has at least 1 item' do
      @inventory.amount = 0
      @inventory.should_not be_valid
      @inventory.amount = 1
      @inventory.should be_valid
    end

    describe 'when listed on market' do
      before do
        @inventory.item.update_attribute(:can_be_sold_on_market, true)
        
        @market_item = Factory(:market_item, :inventory => @inventory, :amount => 4)
      end
      
      [:name, :plural_name, :description, :pictures, :image?, :effects, :effects?, :payouts, :placements].each do |method|
        it "should delegate :#{method} method to inventory" do
          @market_item.send(method).should === @market_item.inventory.send(method)
        end
      end
      
      it 'should destroy market item if new amount is less than amount listed on market' do
        @inventory.amount = 3
        
        lambda{
          @inventory.save
        }.should change(MarketItem, :count).by(-1)
        
        @inventory.market_item.should be_frozen
      end
      
      it 'should not change market item if new amount is equal or greater than listed' do
        @inventory.amount = 4
        
        lambda{
          @inventory.save
        }.should_not change(MarketItem, :count)
        
        @inventory.market_item.should == @market_item
      end
    end
  end
  
  describe '#usable?' do
    it 'should return true' do
      @inventory.should be_usable
    end
    
    it 'should return false if item is not usable' do
      @inventory.item.should_receive(:usable?).and_return(false)
      
      @inventory.should_not be_usable
    end
    
    it 'should return false if inventory was destroyed' do
      @inventory.destroy
      
      @inventory.should_not be_usable
    end
  end

  describe '#use' do
    it "should return false if item is not usable" do
      @inventory.should_receive(:usable?).and_return(false)

      @inventory.payouts.should_not_receive(:apply)

      @inventory.use!.should be_false
    end

    it "should apply usage payouts" do
      @inventory.payouts.should_receive(:apply).with(@character, :use, @item).and_return(Payouts::Collection.new)
      
      @inventory.use!
    end

    it "should save applied payouts to character" do
      @inventory.use!
      @inventory.character.should_not be_changed
    end

    it "should take item from user's inventory" do
      lambda{
        @inventory.use!
      }.should change(@character.inventories, :count).from(1).to(0)
    end

    it "should return payout result collection" do
      result = @inventory.use!

      result.should be_kind_of(Payouts::Collection)

      result.items.first.should be_kind_of(Payouts::BasicMoney)
      result.items.first.value.should == 100
    end
  end

  describe 'when checking if inventory is equipped' do
    before do
      @inventory = Factory(:inventory)
    end

    it 'should return false if no items of current type are equipped' do
      @inventory.equipped?.should be_false
    end

    it 'should return true if at least one item is equipped' do
      @inventory.equipped = 1

      @inventory.equipped?.should be_true
    end
  end
end