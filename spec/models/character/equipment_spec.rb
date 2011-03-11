require 'spec_helper'

describe Character::Equipment do
  describe '#unequip' do
    before do
      @character = Factory(:character)
      @inventory = Factory(:inventory, :character => @character)
      
      @character.equipment.auto_equip!(@inventory)
    end
    
    it 'should remove item ID from passed placement' do
      @character.equipment.unequip(@inventory, :additional)
      
      @character.placements.values.flatten.count(@inventory.id).should == 4
    end
    
    it 'should reduce amount of equipped inventory' do
      lambda{
        @character.equipment.unequip(@inventory, :additional)
      }.should change(@inventory, :equipped).by(-1)
    end
    
    it 'should clear cached inventory list' do
      lambda{
        @character.equipment.unequip(@inventory, :additional)
      }.should change(@character.equipment, :inventories)
    end
  end
  
  describe '#unequip!' do
    before do
      @character = Factory(:character)
      @inventory = Factory(:inventory, :character => @character)
      
      @character.equipment.auto_equip!(@inventory)
    end

    it 'should unequip inventory' do
      @character.equipment.should_receive(:unequip).with(@inventory, :additional)
      
      @character.equipment.unequip!(@inventory, :additional)
    end
    
    it 'should save inventory' do
      @character.equipment.unequip!(@inventory, :additional)
      
      @inventory.should_not be_changed
    end
    
    it 'should save character' do
      @character.equipment.unequip!(@inventory, :additional)
      
      @character.should_not be_changed
    end
    
    it 'should clear inventory effect cache' do
      @character.equipment.should_receive(:clear_effect_cache!)
      
      @character.equipment.unequip!(@inventory, :additional)
    end
  end
end