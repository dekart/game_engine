require "spec_helper"

describe InventoryState do
  let :inventory do
    InventoryState.new do |i|
      i.character = FactoryGirl.create(:character)
      i.give(item)
      i.save
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

  let :purchaseable_item do
    GameData::Item.define :purchaseable_item do |i|
      i.tags = [:shop]

      i.basic_price = 5
      i.vip_price = 3
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
    it 'should return zero if there is no such item in inventory' do
      inventory.take(item)
      inventory.amount(item).must_equal 0
    end

    it 'should return amount of item in inventory' do
      inventory.amount(item).must_equal 1
      inventory.give(item)
      inventory.amount(item).must_equal 2
    end
  end

  describe '#equipped_amount' do
    it 'should return amount of item equipped to slots' do
      inventory.equipped_amount(item).must_equal 0
      inventory.equip(item, :left_hand)
      inventory.equipped_amount(item).must_equal 1
    end

    it 'should return zero if item is not equipped' do
      inventory.equipped_amount(item).must_equal 0
    end
  end

  describe '#equippable_amount' do
    it 'should return amount of item available for equipment' do
      inventory.equippable_amount(item).must_equal 1
    end

    it 'should return zero if all items of this kind are equipped' do
      inventory.equippable_amount(item).must_equal 1
      inventory.equip(item, :left_hand)
      inventory.equippable_amount(item).must_equal 0
    end
  end

  describe '#give' do
    it 'should increase amount of item in inventory by passed value' do
      inventory.amount(item).must_equal 1
      inventory.give(item, 2)
      inventory.amount(item).must_equal 3
    end

    it 'should increase amount of item in inventory by 1 if no amount value passed' do
      inventory.amount(item).must_equal 1
      inventory.give(item)
      inventory.amount(item).must_equal 2
    end
  end

  describe '#take' do
    it 'should decrease amount of item in inventory by passed value' do
      inventory.give(item, 2)
      inventory.amount(item).must_equal 3
      inventory.take(item, 2)
      inventory.amount(item).must_equal 1
    end

    it 'should decrease amount of item in inventory by 1 if no amount value passed' do
      inventory.amount(item).must_equal 1
      inventory.take(item)
      inventory.amount(item).must_equal 0
    end

    it 'should not allow item amount to become negative' do
      inventory.amount(item).must_equal 1
      inventory.take(item, 5)
      inventory.amount(item).must_equal 0
    end
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


  describe '#buy' do
    before do
      inventory.character.basic_money = 100
      inventory.character.vip_money = 100
    end

    describe 'when item is not for sale for this character' do
      it 'should return false' do
        purchaseable_item.stub(:purchaseable_for?, false) do
          inventory.buy!(purchaseable_item).must_equal false
        end
      end
    end

    describe 'when character does not have enough money' do
      before do
        inventory.character.basic_money = 0
        inventory.character.vip_money = 0
      end

      it 'should return a requirement' do
        result = inventory.buy!(purchaseable_item)
        result.must_be_kind_of Requirement
      end

      it 'should return a requirement with basic_money value set' do
        inventory.buy!(purchaseable_item).basic_money.must_equal 5
      end

      it 'should return a requirement with vip_money value set' do
        inventory.buy!(purchaseable_item).vip_money.must_equal 3
      end
    end

    describe 'when all things clear for purchase' do
      it 'should return true' do
        inventory.buy!(purchaseable_item).must_equal true
      end

      it 'should allow to pass item by id, key, or item itself' do
        inventory.buy!(purchaseable_item).must_equal true
        inventory.buy!(purchaseable_item.key).must_equal true
        inventory.buy!(purchaseable_item.id).must_equal true
      end

      it 'should charge basic money' do
        inventory.character.basic_money.must_equal 100
        inventory.buy!(purchaseable_item)
        inventory.character.basic_money.must_equal 95
      end

      it 'should charge vip money' do
        inventory.character.vip_money.must_equal 100
        inventory.buy!(purchaseable_item)
        inventory.character.vip_money.must_equal 97
      end

      it 'should increment amount of items owned by character by a purchased value' do
        inventory.amount(purchaseable_item).must_equal 0
        inventory.buy!(purchaseable_item)
        inventory.amount(purchaseable_item).must_equal 1
      end

      describe 'when purchasing item in packages' do
        before do
          purchaseable_item.package_size = 10
        end

        it 'should increment amount of owned items by a total amount of items' do
          inventory.amount(purchaseable_item).must_equal 0
          inventory.buy!(purchaseable_item)
          inventory.amount(purchaseable_item).must_equal 10
        end
      end

      it 'must persist character and inventory changes' do
        inventory.buy!(purchaseable_item)

        inventory.amount(purchaseable_item).must_equal 1
        inventory.character.basic_money.must_equal 95

        InventoryState.find(inventory.id).amount(purchaseable_item).must_equal 1
        InventoryState.find(inventory.id).character.basic_money.must_equal 95
      end

      it 'should add a record to character news'

      it 'should increment global owned item counter'
    end
  end
end