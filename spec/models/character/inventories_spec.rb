require 'spec_helper'

describe Character do
  describe 'when purchasing item' do
    before do
      @character = Factory(:character)
      @item = Factory(:item)
    end
    
    it 'should give one item to character' do
      lambda{
        @character.inventories.buy!(@item)
      }.should change(@character.inventories, :count).from(0).to(1)

      @character.inventories.first.item.should == @item
      @character.inventories.first.amount.should == 1
    end

    it 'should charge money from character' do
      lambda{
        @character.inventories.buy!(@item)
      }.should change(@character, :basic_money).from(1100).to(1090)
    end

    it 'should increment item usage counter' do
      @character.inventories.buy!(@item)

      @item.reload.owned.should == 1
    end

    it 'should equip item' do
      inventory = @character.inventories.buy!(@item)

      inventory.equipped?.should be_true
    end

    it 'should add news about purchased item' do
      lambda{
        @character.inventories.buy!(@item)
      }.should change(@character.news, :count).from(0).to(1)

      @character.news.first.should be_kind_of(News::ItemPurchase)
      @character.news.first.item.should == @item
      @character.news.first.amount.should == 1
    end

    it 'should return inventory as result' do
      result = @character.inventories.buy!(@item)

      result.should be_kind_of(Inventory)
      result.character.should == @character
      result.item.should == @item
      result.amount.should == 1
    end

    describe 'when amount is set to 3' do
      it 'should give 3 items to character' do
        lambda{
          @character.inventories.buy!(@item, 3)
        }.should change(@character.inventories, :count).from(0).to(1)
        
        @character.inventories.first.amount.should == 3
      end

      it 'should charge money for 3 items' do
        lambda{
          @character.inventories.buy!(@item, 3)
        }.should change(@character, :basic_money).from(1100).to(1070)
      end

      it 'should increment item usage counter by 3' do
        @character.inventories.buy!(@item, 3)

        @item.reload.owned.should == 3
      end
    end

    describe 'when item is sold in package of 5' do
      before do
        @item = Factory(:item, :package_size => 5)
      end

      it 'should give 5 items to character' do
        lambda{
          @character.inventories.buy!(@item)
        }.should change(@character.inventories, :count).from(0).to(1)

        @character.inventories.first.amount.should == 5
      end

      it 'should charge money for 1 item' do
        lambda{
          @character.inventories.buy!(@item)
        }.should change(@character, :basic_money).from(1100).to(1090)
      end

      it 'should increment item usage counter by 5' do
        @character.inventories.buy!(@item)

        @item.reload.owned.should == 5
      end

      it 'should moltiply package size values to 3 when amount is set to 3' do
        lambda{
          @character.inventories.buy!(@item, 3)
        }.should change(@character.inventories, :count).from(0).to(1)

        @character.inventories.first.amount.should == 15
        @character.basic_money.should == 1070
        @item.reload.owned.should == 15
      end
    end
  end
end