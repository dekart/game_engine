require 'spec_helper'

describe Item do
  describe 'scopes' do
    before do
      @item_1 = Factory(:item, :basic_price => 10, :level => 1, :state => 'visible')
      @item_2 = Factory(:item, :basic_price => 20, :level => 1, :state => 'visible')
      @item_3 = Factory(:item, :basic_price => 30, :level => 3, :state => 'visible')

      @character = Factory(:character)
    end

    describe '.available_for' do
      it 'should select items, available for character for given level' do
        Item.available_for(@character).all.should == [@item_1, @item_2]
      end
    
      it 'should not include invisible items' do
        @item_1.hide
        
        Item.available_for(@character).all.should == [@item_2]
      end
    end
    
    it 'should select boost items' do
      @boost = Factory(:item, :boost_type => 'fight')
      
      Item.boosts.should == [@boost]
      Item.boosts('fight').should == [@boost]
    end
  end
  
  describe '.to_grouped_dropdown' do
    before do
      @item_group_1 = Factory(:item_group)
      @item_group_2 = Factory(:item_group)
      
      @item_1 = Factory(:item, :item_group => @item_group_1)
      @item_2 = Factory(:item, :item_group => @item_group_1, :level => 2)
      @item_3 = Factory(:item, :item_group => @item_group_2)
    end
    
    it 'should return grouped groupdown with all items' do
      Item.to_grouped_dropdown.should == { 
        @item_group_1.name => [
          Item.select_option(@item_1), 
          Item.select_option(@item_2)
        ],
        @item_group_2.name => [
          Item.select_option(@item_3)
        ]
      }
    end
    
    it 'should scope items returned by dropdown' do
      Item.scoped(:conditions => 'level = 1').to_grouped_dropdown.should == {
        @item_group_1.name => [
          Item.select_option(@item_1)
        ],
        @item_group_2.name => [
          Item.select_option(@item_3)
        ]
      }
    end
  end

  describe 'when creating' do
    before do
      @item = Factory.build(:item)
    end

    it 'should validate numericality of package size' do
      @item.should validate_numericality_of(:package_size)
    end

    it 'should validate that package size is greater than zero' do
      @item.package_size = 0

      @item.should_not be_valid
    end
  end

  describe 'when getting package size' do
    before do
      @item = Factory(:item)
    end

    it 'should return 1 when package size is not set' do
      @item.package_size.should == 1
    end

    it 'should return value when package size is set' do
      @item.package_size = 5

      @item.package_size.should == 5
    end
  end

  describe 'when checking if item can be sold' do
    before do
      @item = Factory(:item, :can_be_sold => true)
    end

    it 'should return true if flag is set and package size is 1' do
      @item.can_be_sold?.should be_true
    end

    it 'should return false if flag is not set' do
      @item.can_be_sold = false

      @item.can_be_sold?.should be_false
    end

    it 'should return false if package size is larger than 1' do
      @item.package_size = 2

      @item.can_be_sold?.should be_false
    end
  end
end
