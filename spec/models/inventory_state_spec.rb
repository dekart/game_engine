require "spec_helper"

describe InventoryState do
  let :inventory do
    InventoryState.new do |i|
      i.character = Factory(:character)
      i.give(item)
    end
  end

  let :item do
    GameData::Item.define :some_item do |i|
      i.placements = [:left_hand, :additional]
      i.effects = {:attack => 1, :defence => 2}
    end
  end

  let :another_item do
    GameData::Item.define :another_item do |i|
      i.placements = [:left_hand, :additional]
      i.effects = {:attack => 3, :defence => 4}
    end
  end

  describe "#inventory" do
    it "should create new data hash if it does not exist yet" do
      i = InventoryState.new

      i.inventory.must_be_kind_of(Hash)

      i.inventory[:items].must_be_kind_of(Hash)
      i.inventory[:items][:non_existent_key].must_equal 0

      i.inventory[:placements].must_be_kind_of(Hash)
      i.inventory[:placements][:non_existent_key].must_be_nil
    end

    it "should deserialize previously saved data" do
      i = InventoryState.new

      i.inventory[:items][1] = 2
      i.inventory[:placements][:left_hand] = [[1, 1]]

      i.save

      InventoryState.first.inventory.must_equal(
        {:items=>{1=>2}, :placements=>{:left_hand=>[[1, 1]]}}
      )
    end
  end

  describe '#amount' do
    it 'should return amount of item in inventory'
    it 'should return zero if there is no such item in inventory'
  end

  describe '#equipped_amount' do
    it 'should return amount of item equipped to slots'
    it 'should return zero if item is not equipped'
  end

  describe '#equippable_amount' do
    it 'should return amount of item available for equipment'
    it 'should return zero if all items of this kind are equipped'
  end

  describe '#give' do
    it 'should increase amount of item in inventory by passed value'
  end

  describe '#take' do
    it 'should decrease amount of item in inventory by passed value'
    it 'should not allow item amount to become negative'
  end

  describe '#equip' do
    it 'should increase equipped amount of item' do
      inventory.amount(item).must_equal 1
      inventory.equipped_amount(item).must_equal 0

      inventory.equip(item, :left_hand)
      inventory.equipped_amount(item).must_equal 1
    end

    describe 'when placing to additional slot' do
      it 'should create slot and put item there if slot is empty' do
        inventory.inventory[:placements][:additional].must_be_nil

        inventory.equip(item, :additional)
        inventory.inventory[:placements][:additional].must_equal [[item.id, 1]]
      end

      it 'should add item to slot if it is not there' do
        inventory.equip(item, :additional)

        inventory.give(another_item)
        inventory.equip(another_item, :additional)
        inventory.inventory[:placements][:additional].must_include [another_item.id, 1]
      end

      it 'should increase amount of item in the slot if it is already there' do
        inventory.equip(item, :additional)
        inventory.equipped_amount(item).must_equal 1

        inventory.give(item)
        inventory.equip(item, :additional)
        inventory.inventory[:placements][:additional].assoc(item.id)[1].must_equal 2
      end

    end

    describe 'when placing to single item slot' do
      it 'should create slot and put item there if slot is empty' do
        inventory.inventory[:placements][:left_hand].must_be_nil

        inventory.equip(item, :left_hand)
        inventory.inventory[:placements][:left_hand].must_equal [[item.id, 1]]
      end

      it 'should replace existing item if slot is used' do
        inventory.equip(item, :left_hand)
        inventory.inventory[:placements][:left_hand].must_equal [[item.id, 1]]

        inventory.give(another_item)
        inventory.equip(another_item, :left_hand)
        inventory.inventory[:placements][:left_hand].must_equal [[another_item.id, 1]]
      end
    end

    it 'should not equip item if all instances of item are already equipped' do
      inventory.equip(item, :left_hand)
      inventory.equipped_amount(item).must_equal 1

      inventory.equip(item, :right_hand)
      inventory.equipped_amount(item).must_equal 1
    end

    it 'should not equip item if it cannot be equipped to requested slot' do
      inventory.equipped_amount(item).must_equal 0
      inventory.equip(item, :head)
      inventory.equipped_amount(item).must_equal 0
    end

    it 'should force effect recalculation' do
      inventory.effects.must_equal({})

      inventory.equip(item, :additional)
      inventory.effects.must_equal({:attack => 1, :defence => 2})
    end
  end

  describe '#unequip' do
    it 'should not change equipped amount if there is no such item equipped to the requested slot' do
      inventory.equip(item, :left_hand)
      inventory.equipped_amount(item).must_equal 1

      inventory.unequip(item, :additional)
      inventory.equipped_amount(item).must_equal 1
    end

    it 'should decrease total number of items equipped' do
      inventory.give(item, 2)
      inventory.equip(item, :additional)
      inventory.equip(item, :additional)

      inventory.equipped_amount(item).must_equal 2

      inventory.unequip(item, :additional)
      inventory.equipped_amount(item).must_equal 1
    end

    it 'should decrease number of item equipped to the slot' do
      inventory.give(item, 2)
      inventory.equip(item, :additional)
      inventory.equip(item, :additional)
      inventory.equipped_amount(item).must_equal 2
      inventory.inventory[:placements][:additional].assoc(item.id).last.must_equal 2

      inventory.unequip(item, :additional)
      inventory.equipped_amount(item).must_equal 1
      inventory.inventory[:placements][:additional].assoc(item.id).last.must_equal 1
    end

    it 'should completely remove item from the slot if we unequip last item' do
      inventory.give(item, 2)
      inventory.equip(item, :additional)
      inventory.equip(item, :additional)
      inventory.equipped_amount(item).must_equal 2
      inventory.inventory[:placements][:additional].assoc(item.id).last.must_equal 2

      inventory.unequip(item, :additional)
      inventory.unequip(item, :additional)
      inventory.equipped_amount(item).must_equal 0
      inventory.inventory[:placements][:additional].assoc(item.id).must_be_nil
    end

    it 'should force effect recalculation' do
      inventory.equip(item, :additional)
      inventory.effects.must_equal({:attack => 1, :defence => 2})

      inventory.unequip(item, :additional)
      inventory.effects.must_equal({})
    end
  end


  describe '#effects' do
    it 'should return hash of effects' do
      inventory.effects.must_be_kind_of Hash
    end

    it 'should return zero for non-existent effect values' do
      inventory.effects[:non_existent_attribute].must_equal 0
    end

    it 'should not sum unequipped item effects' do
      inventory.give(item)
      inventory.give(another_item)
      inventory.effects.must_equal({})
    end

    it 'should sum all equipped item effects' do
      inventory.give(item)
      inventory.give(another_item)
      inventory.equip(item, :left_hand)
      inventory.equip(item, :additional)
      inventory.equip(another_item, :additional)

      inventory.effects.must_equal({:attack => 1 + 1 + 3, :defence => 2 + 2 + 4})
    end

    it 'should cache effect values' do
      inventory.give(another_item)
      inventory.equip(item, :left_hand)
      inventory.equip(another_item, :additional)
      inventory.effects.must_equal({:attack => 1 + 3, :defence => 2 + 4})

      item.effects[:some_effect] = 1
      another_item.effects[:some_effect] = 2

      inventory.effects[:some_effect].must_equal 0
    end
  end
end