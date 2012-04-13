require 'spec_helper'

describe Character::Equipment::Inventories::Inventory do
  before :each do
    @character = Factory(:character)
    @item = Factory(:item)
    @inventory = @character.inventories.give!(@item)
  end

  it "should delegate payouts to item" do
    @inventory.payouts.should === @inventory.item.payouts
  end
  
  describe '#save' do
    before do
      @inventory = @character.inventories.give!(@item)
    end
    
    it 'should validate that inventory has at least 1 item' do
      @inventory.amount.should > 0
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
  end

  describe '#use' do
    it "should return false if item is not usable" do
      @inventory.item.should_receive(:usable?).and_return(false)

      @inventory.payouts.should_not_receive(:apply)

      @inventory.use!(@character).should be_false
    end

    it "should apply usage payouts" do
      @inventory.should_receive(:usable?).and_return(true)
      
      @inventory.payouts.should_receive(:apply).with(@character, :use, @inventory.item).and_return(Payouts::Collection.new)
      
      @inventory.use!(@character)
    end

    it "should save applied payouts to character" do
      @inventory.use!(@character)
      @character.should_not be_changed
    end

    it "should take item from user's inventory" do
      lambda{
        @inventory.use!(@character)
      }.should change(@character.inventories, :size).from(1).to(0)
    end

    it "should return payout result collection" do
      result = @inventory.use!(@character)

      result.should be_kind_of(Payouts::Collection)

      result.items.first.should be_kind_of(Payouts::BasicMoney)
      result.items.first.value.should == 100
    end
  end

  describe 'when checking if inventory is equipped' do
    before do
      @inventory = @character.inventories.give!(@item)
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