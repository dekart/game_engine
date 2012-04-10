require 'spec_helper'

describe Character::Equipment do
  describe '#effect' do
    before do
      @character  = Factory(:character)
      @item       = Factory(:item, 
        :effects => [
          {:type => :attack, :value => 1}, 
          {:type => :defence, :value => 2}
        ]
      )

      @character.inventories.give!(@item, 1)
      @character.equipment.auto_equip!(@item)
    end
    
    it 'should read cached values from Rails cache' do
      Rails.cache.write("character_#{@character.id}_equipment_effects", [{:attack => 123}, []])
      
      @character.equipment.effect(:attack).should == 123
    end
    
    describe 'when cache is empty' do
      before do
        Rails.cache.clear
      end
      
      it 'should collect all effects from equipped inventories' do
        Effects::Base::BASIC_TYPES.each do |attribute|
          @item.should_receive(:effect).with(attribute).and_return(1)
        end
        
        @character.equipment.effect(:attack)
      end
      
      it 'should not re-collect effects' do
        Effects::Base::BASIC_TYPES.each do |effect|
          @item.should_receive(:effect).with(effect).once
        end
        
        @character.equipment.effect(:attack)
        @character.equipment.effect(:attack)
      end
    
      it 'should return value of the requested effect' do
        @character.equipment.effect(:attack).should == 1
      end
    end
    
    describe 'restore rate' do
      it 'should increase hp restore rate' do
        lambda {
          @item.update_attributes!(:effects => [{:type => :hp_restore_rate, :value => 10}])
          @character.equipment.auto_equip!(@item)
        }.should change(@character, :health_restore_period).from(60).to(54)
      end
      
      it 'should increase ep restore rate' do
        lambda {
          @item.update_attributes!(:effects => [{:type => :ep_restore_rate, :value => 10}])
          @character.equipment.auto_equip!(@item)
        }.should change(@character, :energy_restore_period).from(120).to(108)
      end
      
      it 'should increase sp restore rate' do
        lambda {
          @item.update_attributes!(:effects => [{:type => :sp_restore_rate, :value => 10}])
          @character.equipment.auto_equip!(@item)
        }.should change(@character, :stamina_restore_period).from(180).to(162)
      end
    end
    
  end
  
  
  describe '#inventories' do
    before do
      @character = Factory(:character)
      @item1 = Factory(:item)
      @item2 = Factory(:item)

      @character.inventories.give!(@item1, 2)
      @character.inventories.give!(@item2, 2)

      @character.equipment.placements = {
        :additional => [@item1.id, @item2.id], 
        :left_hand  => [@item1.id],
        :right_hand => [@item2.id]
      }
    end
       
    it 'should collect an array of inventories respective to number of their IDs' do
      @character.equipment.inventories.count(@item1).should == 2
      @character.equipment.inventories.count(@item2).should == 2
    end
    
    it 'should return empty array if character doesn\'t have equipped inventories' do
      @character.equipment.placements = {}
      @character.inventories.each{|inventory| inventory.equipped = 0}
      
      @character.equipment.inventories.equipped.should be_empty
    end
  end
  
  
  describe '#inventories_by_placement' do
    before do
      @character = Factory(:character)
      @item1 = Factory(:item)
      @item2 = Factory(:item)
      
      @character.inventories.give!(@item1, 2)
      @character.inventories.give!(@item2, 2)
      
      @character.equipment.placements = {
        :additional => [@item1.id, @item2.id], 
        :left_hand  => [@item1.id],
        :right_hand => [@item2.id]
      }
    end

    it 'should return array of inventories by their IDs stored in defined placement' do
      @character.equipment.inventories_by_placement(:additional).should == 
        [@character.inventories.find_by_item(@item1), @character.inventories.find_by_item(@item2)]
      
      @character.equipment.inventories_by_placement(:left_hand).should == 
        [@character.inventories.find_by_item(@item1)]
    end
    
    it 'should return empty array if there are no equipped items in the placement' do
      @character.equipment.inventories_by_placement(:empty_placement).should == []
    end
  end
  
  
  describe '#equip' do
    describe 'when placement have free space' do
      it 'should inventory ID to the placement'
      it 'recalculate equipped amount for inventory'
    end
    
    describe 'when placement does not have free space' do
      describe 'when placement is a main placement' do
        it 'should unequip previous inventory'
        it 'should equip passed inventory'
        it 'should return previous inventory'
        it 'should not try to re-equip inventory'
      end
    end
    
    it 'should return nil if inventory is not equippable'
    it 'should return nil if inventory cannot be put to this placement'
  end
  
  
  describe '#equip!' do
    before do
      @character = Factory(:character)
      @item = Factory(:item)
      
      @character.inventories.give!(@item)
    end
    
    it 'should equip inventory' do
      @character.equipment.should_receive(:equip).with(@item, :left_hand).and_return(nil)
      
      @character.equipment.equip!(@item, :left_hand)
    end
     
    it 'should save inventory' do
      @character.equipment.equip!(@item, :left_hand)
      
      @item.should_not be_changed
    end
    
    it 'should save character' do
      @character.equipment.equip!(@item, :left_hand)
      
      @item.should_not be_changed
    end
    
    it 'should clear effect cache' do
      @character.equipment.should_receive(:clear_effect_cache!)
      
      @character.equipment.equip!(@item, :left_hand)
    end
    
    it 'should actually put inventory to the placement' do
      @character.equipment.inventories_by_placement(:left_hand).should be_empty
      
      @character.equipment.equip!(@item, :left_hand)
      
      @character.reload.equipment.inventories_by_placement(:left_hand).should 
        include @character.inventories.find_by_item(@item)
    end
  end
  
  
  describe '#unequip' do
    before do
      @character = Factory(:character)
      @item = Factory(:item)
      
      @character.inventories.give!(@item, 5)
      @character.equipment.auto_equip!(@item)
    end
    
    it 'should remove item ID from passed placement' do
      @character.equipment.unequip(@item, :additional)
      
      @character.placements.values.flatten.count(@item.id).should == 4
    end
    
    it 'should reduce amount of equipped inventory' do
      inventory = @character.inventories.find_by_item(@item)
      
      lambda{
        @character.equipment.unequip(@item, :additional)
      }.should change(inventory, :equipped).by(-1)
    end
    
    it 'should clear cached inventory list' do
      lambda{
        @character.equipment.unequip!(@item, :additional)
      }.should change(@character.equipment, :inventories)
    end
  end
  
  
  describe '#unequip!' do
    before do
      @character = Factory(:character)
      @item = Factory(:item)
      
      @character.inventories.give!(@item, 5)
      @character.equipment.auto_equip!(@item)
    end

    it 'should unequip inventory' do
      @character.equipment.should_receive(:unequip).with(@item, :additional)
      
      @character.equipment.unequip!(@item, :additional)
    end
    
    it 'should save inventory' do
      @character.equipment.unequip!(@item, :additional)
      
      @item.should_not be_changed
    end
    
    it 'should save character' do
      @character.equipment.unequip!(@item, :additional)
      
      @character.should_not be_changed
    end
    
    it 'should clear inventory effect cache' do
      @character.equipment.should_receive(:clear_effect_cache!)
      
      @character.equipment.unequip!(@item, :additional)
    end
  end

  describe 'best inventory' do
    before do
      @character  = Factory(:character)

      @item1 = Factory(:item,
        :effects => [
          {:type => :attack, :value => 10},
          {:type => :defence, :value => 1}
        ]
      )
      @item2 = Factory(:item,
        :effects => [
          {:type => :attack, :value => 1},
          {:type => :defence, :value => 10}
        ]
      )
      @item3 = Factory(:item,
        :effects => [
          {:type => :attack, :value => 5},
          {:type => :defence, :value => 5}
        ]
      )
      @item4 = Factory(:item,
        :effects => [
          {:type => :attack, :value => 2},
          {:type => :defence, :value => 2}
        ]
      )

      @character.inventories.give!(@item1)
      @character.inventories.give!(@item2)
      @character.inventories.give!(@item3)
      @character.inventories.give!(@item4)

      @character.equipment.equip!(@item1, :left_hand)
      @character.equipment.equip!(@item2, :additional)
      @character.equipment.equip!(@item3, :additional)
      @character.equipment.equip!(@item4, :additional)
    end

    it 'should return best offence items' do
      @character.equipment.best_offence.should == [@item1, @item3, @item4]
    end

    it 'should return best defence items' do
      @character.equipment.best_defence.should == [@item2, @item3, @item4]
    end
  end
end