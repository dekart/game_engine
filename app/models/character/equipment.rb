class Character::Equipment
  MAIN_PLACEMENTS = [:left_hand, :right_hand, :head, :body, :legs]
  PLACEMENTS = MAIN_PLACEMENTS + [:additional]

  IMAGE_SIZES = {
    :left_hand  => :medium,
    :right_hand => :medium,
    :head       => :small,
    :body       => :medium,
    :legs       => :medium,
    :additional => :small
  }

  class << self
    def placement_name(name)
      I18n.t("inventories.placements.names.#{name}", :default => name.to_s.humanize)
    end
  end

  def initialize(character)
    @character = character
  end

  def inventories(placement = nil)
    ids = placement ? @character.placements[placement.to_sym] : @character.placements.collect{|key, value| value}.flatten
    ids ||= []
    
    if ids.any?
      inventories = Inventory.find(ids)

      ids.collect do |id|
        inventories.detect{|inventory| inventory.id == id}
      end
    else
      ids
    end
  end

  def equip(inventory, placement)
    placement = placement.to_sym

    return unless inventory.placements.include?(placement)

    if placement_free_space(placement) > 0 and inventory.amount_available_for_equipment > 0
      inventory.increment(:equipped)

      @character.placements[placement] ||= []
      @character.placements[placement] << inventory.id
    end
  end

  def equip!(inventory, placement)
    Character.transaction do
      equip(inventory, placement)

      inventory.save!
      @character.save!
    end
  end

  def auto_equip!(inventory)
    inventory.amount_available_for_equipment.times do
      if placement = (placements_with_free_space & inventory.placements).first
        equip(inventory, placement)
      else
        break
      end
      puts "i"
    end

    Character.transaction do
      inventory.save!
      @character.save!
    end
  end

  def unequip(inventory, placement)
    placement = placement.to_sym

    if @character.placements[placement] and index = @character.placements[placement].index(inventory.id)
      inventory.decrement(:equipped) unless inventory.frozen?

      @character.placements[placement].delete_at(index)
    end
  end

  def unequip!(inventory, placement)
    Character.transaction do
      unequip(inventory, placement)

      inventory.save!
      @character.save!
    end
  end

  def auto_unequip!(inventory)
    amount_to_unequip = inventory.destroyed? ? inventory.amount : (inventory.equipped - inventory.amount)
    
    return if amount_to_unequip <= 0

    amount_to_unequip.times do
      if placement = placements_with(inventory).last
        unequip(inventory, placement)
      else
        break
      end
    end

    Character.transaction do
      inventory.save! unless inventory.destroyed?
      @character.save!
    end
  end

  def placements_with_free_space
    PLACEMENTS.select{|placement| placement_free_space(placement) > 0 }
  end

  def placement_free_space(placement)
    placement_capacity(placement) - placement_usage(placement)
  end

  def placement_capacity(placement)
    if placement == :additional
      10 # calculate bag capacity here
    else
      1
    end
  end

  def placements_with(inventory)
    PLACEMENTS.select{|placement| @character.placements[placement].try(:include?, inventory.id) }
  end

  def placement_usage(placement)
    @character.placements[placement].try(:size).to_i
  end
end