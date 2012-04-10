require 'spec_helper'

describe Character do
  describe 'when purchasing item' do
    before do
      @character = Factory(:character, :basic_money => 100)
      @item = Factory(:item)
    end

    it 'should give one item to character' do
      lambda{
        @character.inventories.buy!(@item)
      }.should change(@character.inventories, :size).from(0).to(1)

      @character.inventories.first.item.should == @item
      @character.inventories.first.amount.should == 1
    end

    it 'should charge money from character' do
      lambda{
        @character.inventories.buy!(@item)
      }.should change(@character.reload, :basic_money).from(100).to(90)
    end

    it 'should save character' do
      @character.inventories.buy!(@item)
      @character.should_not be_changed
    end
    
    it 'should save character when item is not equippable' do
      @item.placements = nil
      
      @character.inventories.buy!(@item)
      @character.should_not be_changed
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

      result.should be_kind_of(Character::Equipment::Inventories::Inventory)
      result.item.should == @item
      result.amount.should == 1
    end

    describe 'when amount is set to 3' do
      it 'should give 3 items to character' do
        lambda{
          @character.inventories.buy!(@item, 3)
        }.should change(@character.inventories, :size).from(0).to(1)
        
        @character.inventories.first.amount.should == 3
      end

      it 'should charge money for 3 items' do
        lambda{
          @character.inventories.buy!(@item, 3)
        }.should change(@character.reload, :basic_money).from(100).to(70)
      end

      it 'should increment item usage counter by 3' do
        lambda{
          @character.inventories.buy!(@item, 3)
          @item.reload
        }.should change(@item, :owned).by(3)
      end
    end

    describe 'when item is sold in package of 5' do
      before do
        @item = Factory(:item, :package_size => 5)
      end

      it 'should give 5 items to character' do
        lambda{
          @character.inventories.buy!(@item)
        }.should change(@character.inventories, :size).from(0).to(1)

        @character.inventories.first.amount.should == 5
      end

      it 'should charge money for 1 item' do
        lambda{
          @character.inventories.buy!(@item)
        }.should change(@character.reload, :basic_money).from(100).to(90)
      end

      it 'should increment item usage counter by 5' do
        @character.inventories.buy!(@item)

        @item.reload.owned.should == 5
      end

      it 'should multiply package size values to 3 when amount is set to 3' do
        lambda{
          @character.inventories.buy!(@item, 3)
        }.should change(@character.inventories, :size).from(0).to(1)

        @character.inventories.first.amount.should == 15
        @character.reload.basic_money.should == 70
        @item.reload.owned.should == 15
      end
    end
  end

  describe '#sell!' do
    before do
      @character = Factory(:character)
      @item = Factory(:item)
      
      @character.inventories.give!(@item, 5)
    end
    
    it 'should give money to character' do
      lambda{
        @character.inventories.sell!(@item)
      }.should change(@character.reload, :basic_money).by(5)
    end

    it 'take item from character' do
      @character.inventories.should_receive(:take).with(@item, 1)
      
      @character.inventories.sell!(@item)
    end
    
    describe 'when listed on market' do
      before do
        @item.update_attribute(:can_be_sold_on_market, true)
        
        @market_item = Factory(:market_item, :character => @character, :item => @item, :amount => 4)
      end

      it 'should destroy market item if new amount is less than amount listed on market' do
        lambda{
          @character.inventories.sell!(@item, 2)
        }.should change(MarketItem, :count).by(-1)
      end
      
      it 'should not change market item if new amount is equal or greater than listed' do
        lambda{
          @character.inventories.sell!(@item)
        }.should_not change(MarketItem, :count)
        
        @character.market_items.find_by_item_id(@item).should == @market_item
      end
    end
    
    it 'should invalidate exchanges' do
      
    end
  end
  
  describe '#take!' do
    before do
      @character = Factory(:character)
      @item = Factory(:item)
      
      @character.inventories.give!(@item, 5)
    end
    
    it 'should not give money to character' do
      lambda{
        @character.inventories.take!(@item)
      }.should_not change(@character.reload, :basic_money).by(5)
    end
    
    it 'should save character' do
      @character.inventories.take!(@item)
      @character.should_not be_changed
    end
    
    it 'should save character when item is not equippable' do
      @item.placements = nil
      
      @character.inventories.take!(@item)
      @character.should_not be_changed
    end

    describe 'when taking part of available items' do
      it 'should reduce amount if inventory' do
        @inventory = @character.inventories.find_by_item(@item)
        
        lambda{
          @character.inventories.take!(@item)
        }.should change(@inventory, :amount).by(-1)
      end
      
      it 'should reduce owned item count' do
        lambda{
          @character.inventories.take!(@item)
          @item.reload
        }.should change(@item, :owned).by(-1)
      end
    end
    
    describe 'when selling all available items' do
      it 'should reduce owned item count' do
        lambda{
          @character.inventories.take!(@item, 5)
          @item.reload
        }.should change(@item, :owned).by(-5)
      end
      
      it 'should destroy inventory' do
        @character.inventories.sell!(@item, 5)
        @character.inventories.find_by_item(@item).should be_nil
      end
    end
    
    it 'should unequip sold inventory' do
      @character.equipment.auto_equip!(@item)
      
      @character.equipment.inventories.count(@item).should == 5
      
      @character.inventories.take!(@item)
      
      @character.equipment.inventories.count(@item).should == 4
      
      @character.inventories.take!(@item, 4)
      
      @character.equipment.inventories.count(@item).should == 0
    end
    
    it 'should return inventory' do
      @character.inventories.take!(@item).should be_kind_of(Character::Equipment::Inventories::Inventory)
    end
    
    describe 'when character doesn\'t have passed item' do
      before do
        if inventory = @character.inventories.find_by_item(@item)
          @character.inventories.take!(@item, inventory.amount)
        end
      end
      
      it 'should not charge money from character' do
        lambda{
          @character.inventories.take!(@item)
        }.should_not change(@character.reload, :basic_money)
      end
        
      it 'should return false' do
        @character.inventories.take!(@item).should be_false
      end
    end
    
    describe 'when listed on market' do
      before do
        @item.update_attribute(:can_be_sold_on_market, true)
        
        @market_item = Factory(:market_item, :character => @character, :item => @item, :amount => 4)
      end
      
      it 'should destroy market item if new amount is less than amount listed on market' do
        lambda{
          @character.inventories.take!(@item, 2)
        }.should change(MarketItem, :count).by(-1)
      end
      
      it 'should not change market item if new amount is equal or greater than listed' do
        lambda{
          @character.inventories.take!(@item)
        }.should_not change(MarketItem, :count)
        
        @character.market_items.find_by_item_id(@item).should == @market_item
      end
    end
  end
  
  
  describe 'when transferring items from one character to another' do
    before do
      @character1 = Factory(:character)
      @character2 = Factory(:character)

      @item = Factory(:item)

      @character1.inventories.give!(@item, 5)
    end

    it 'should raise exception if passed amount is less than 1' do
      lambda{
        @character1.inventories.transfer!(@character2, @item, 0)
      }.should raise_exception(ArgumentError)

      lambda{
        @character1.inventories.transfer!(@character2, @item, -1)
      }.should raise_exception(ArgumentError)
    end

    it 'should raise exception if source character doesn\'t have enough items' do
      lambda{
        @character1.inventories.transfer!(@character2, @item, 10)
      }.should raise_exception(ArgumentError)
    end
    
    it 'should take items from source character' do
      @character1.inventories.transfer!(@character2, @item, 2)
      
      @character1.inventories.first.amount.should == 3
    end

    it 'should give items to destination character' do
      @character1.inventories.transfer!(@character2, @item, 2)

      @character2.inventories.first.item.should == @item
      @character2.inventories.first.amount.should == 2
    end

    it 'should correctly work when passing inventory' do
      lambda{
        @character1.inventories.transfer!(@character2, @character1.inventories.first.item, 2)
      }.should_not raise_exception

      @character1.inventories.first.amount.should == 3
      @character2.inventories.first.amount.should == 2
    end
  end
end