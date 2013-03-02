class InventoryState < ActiveRecord::Base
  PLACEMENTS = [:right_hand, :left_hand, :head, :body, :legs, :additional]
  ADDITIONAL_SLOTS = 5
  RELATIONS_PER_ADDITIONAL_SLOT = 2

  belongs_to :character, :autosave => true

  before_save :serialize_inventory_data

  def inventory
    @inventory ||= deserialize_inventory_data
  end

  def amount(key)
    inventory[:items][GameData::Item[key].id]
  end

  def equipped_amount(key)
    item_id = GameData::Item[key].id

    inventory[:placements].sum do |placement, items|
      items.sum do |id, amount|
        id == item_id ? amount : 0
      end
    end
  end

  def equippable_amount(key)
    amount(key) - equipped_amount(key)
  end

  def give(key, amount = 1)
    inventory[:items][GameData::Item[key].id] += amount
  end

  def take(key, amount = 1)
    item_id = GameData::Item[key].id

    inventory[:items][item_id] -= amount
    inventory[:items][item_id] = 0 if inventory[:items][item_id] < 0
    inventory[:items][item_id]
  end

  def effects
    @effects ||= calculate_equipped_item_effects
  end

  def equip(key, placement)
    item = GameData::Item[key]
    placement = placement.to_sym

    return unless item.placements.include?(placement) && equippable_amount(item) > 0

    inventory[:placements][placement] ||= []

    if available_capacity(placement) > 0
      if record = inventory[:placements][placement].assoc(item.id)
        record[1] += 1
      else
        inventory[:placements][placement] << [item.id, 1]
      end
    elsif single_item_slot?(placement) and inventory[:placements][placement][0].try(:first) != item.id
      inventory[:placements][placement] = [ [item.id, 1] ]
    end

    @effects = nil
  end

  def unequip(key, placement)
    item = GameData::Item[key]
    placement = placement.to_sym

    if inventory[:placements][placement] and record = inventory[:placements][placement].assoc(item.id)
      if record[1] == 1
        inventory[:placements][placement].delete(record)
      else
        record[1] -= 1
      end

      @effects = nil
    end
  end

  def buy!(key, amount = 1)
    item = GameData::Item[key]

    return false unless item.purchaseable_for?(character)

    basic_price = item.basic_price.to_i * amount
    vip_price   = item.vip_price.to_i * amount

    if character.basic_money < basic_price or character.vip_money < vip_price
      return Requirement.new(character) do |r|
        r.basic_money = basic_price if basic_price > 0
        r.vip_money   = vip_price if vip_price > 0
      end
    end

    character.transaction do
      character.charge(basic_price, vip_price, item)

      give(item, amount * item.package_size)

      save
    end

    true
  end

  protected

  def deserialize_inventory_data
    if self[:inventory].present?
      Marshal.load(self[:inventory])
    else
      {
        :items => Hash.new(0),
        :placements => {}
      }
    end
  end

  def serialize_inventory_data
    if @inventory # only do serialization if inventory was loaded
      self[:inventory] = Marshal.dump(@inventory)
    end
  end

  def calculate_equipped_item_effects
    Hash.new(0).tap do |result|
      inventory[:placements].each do |placement, items|
        items.each do |id, amount|
          item = GameData::Item[id]

          item.effects.each do |effect, value|
            result[effect] += value * amount
          end
        end
      end
    end
  end

  def available_capacity(placement)
    placement_capacity(placement) - used_capacity(placement)
  end

  def placement_capacity(placement)
    case placement
    when :additional
      result = character.character_type.attributes[:equipment_slots] || ADDITIONAL_SLOTS

      if RELATIONS_PER_ADDITIONAL_SLOT > 0
        result += character.relations.effective_size / RELATIONS_PER_ADDITIONAL_SLOT
      end

      result
    else
      1
    end
  end

  def used_capacity(placement)
    (inventory[:placements][placement] || []).sum{|id, amount| amount }
  end

  def single_item_slot?(placement)
    placement != :additional
  end
end