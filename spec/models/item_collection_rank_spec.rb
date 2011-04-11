require 'spec_helper'

describe ItemCollectionRank do
  describe '#apply!' do
    before do
      @collection = Factory(:item_collection)
      @character = Factory(:character)
      
      @collection.items.each do |item|
        @character.inventories.give!(item, 2)
      end
      
      @rank = ItemCollectionRank.new(:character => @character, :collection => @collection)
    end
    
    it 'should return false if character doesn\'t have required items' do
      @character.inventories.take!(@collection.items.first, 2)
      
      @rank.apply!.should be_false
    end
    
    it 'should give collection bonus to character' do
      lambda{
        @rank.apply!
      }.should change(@character, :basic_money).by(123)
    end

    it 'should give repeat collection bonus to character' do
      @rank.apply!
      
      lambda{
        @rank.apply!
      }.should change(@character, :vip_money).by(1)
    end
    
    it 'should take items from character' do
      @character.inventories.each do |i|
        i.amount.should == 2
      end
      
      @rank.apply!

      @character.reload.inventories.each do |i|
        i.amount.should == 1
      end
    end
    
    it 'should increment collection count' do
      lambda{
        @rank.apply!
      }.should change(@rank, :collection_count).by(1)
    end
    
    it 'should become applied' do
      @rank.apply!
      
      @rank.should be_applied
    end
    
    it 'should set applied payouts (both given and taken)' do
      @rank.apply!
      
      @rank.payouts.size.should == 4
      @rank.payouts.should be_kind_of(Payouts::Collection)
      @rank.payouts.first.should be_kind_of(Payouts::BasicMoney)
      @rank.payouts[1..-1].each_with_index do |p, i|
        p.should be_kind_of(Payouts::Item)
        p.item.should == @collection.items[i]
      end
    end
    
    it 'should save character' do
      @rank.apply!
      
      @character.should_not be_changed
    end
    
    it 'should save rank' do
      @rank.apply!
      
      @rank.should_not be_changed
    end
    
    it 'should return true' do
      @rank.apply!.should be_true
    end
  end
end