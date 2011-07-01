require 'spec_helper'

describe Character::Boosts do
  before do
    @item = Factory(:item, :boost_type => 'fight')
    @character = Factory(:character)
  end
  
  it 'character should have fight boost' do
    @item.update_attribute(:boost_type, 'fight')
    @character.inventories.give!(@item)
    
    @character.boosts.by_type(:fight).first.item.should == @item
  end
  
  it 'character should have monster boost' do
    @item.update_attribute(:boost_type, 'monster')
    @character.inventories.give!(@item)
    
    @character.boosts.by_type(:monster).first.item.should == @item
  end
end