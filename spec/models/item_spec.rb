require 'spec_helper'

describe Item do
  before do
    item_group = Factory.create :item_group
    @item_1 = Factory.create :item, :basic_price => 10, :name => 'item_1', :item_group => item_group, :level => 1
    @item_2 = Factory.create :item, :basic_price => 20, :name => 'item_2', :item_group => item_group, :level => 1
    @item_3 = Factory.create :item, :basic_price => 30, :name => 'item_3', :item_group => item_group, :level => 3
  
    @ctype = Factory.create :character_type
    @character = Factory.create :character, :character_type => @ctype, :level => 1
  end

  it 'should select items, available for character for given level' do
    Item.available_for(@character).all.should == [@item_1, @item_2]
  end

  it 'should not select items, marked as hidden' do
    @item_2.itypes << @ctype 
    Item.available_for(@character).all.should == [@item_1]
  end
end
