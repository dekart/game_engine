require 'spec_helper'

describe Inventory do
  before :each do
    @character = Factory(:character)
    @item = Factory(:item)
    @inventory = @character.inventories.create!(:item => @item)
  end

  it "should delegate payouts to item" do
    @inventory.payouts.should === @item.payouts
  end

  describe "when using it" do
    it "should return false if item is not usable" do
      @inventory.should_receive(:usable?).and_return(false)

      @inventory.payouts.should_not_receive(:apply)

      @inventory.use!.should be_false
    end

    it "should apply usage payouts" do
      @inventory.payouts.should_receive(:apply).with(@character, :use).and_return(Payouts::Collection.new)
      
      @inventory.use!
    end

    it "should save applied payouts to character" do
      @inventory.character.should_receive(:save!).and_return(true)

      @inventory.use!
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
end