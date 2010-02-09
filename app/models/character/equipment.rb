class Character::Equipment
  PLACEMENTS = [:left_hand, :right_hand, :head, :body, :additional]

  class << self
    def placement_name(name)
      I18n.t("characters.placements.#{name}")
    end
  end

  def initialize(character)
    @character = character
  end

  def inventories(placement = nil)
    ids = placement ? @character.placements[placement.to_sym] : @character.placements.collect{|key, value| value}.flatten

    ids.any? ? Inventory.find(ids) : []
  end

  def enough_room?(placement)
    placement_capacity(placement) >= placement_usage(placement)
  end

  def placement_capacity(placement)
    if placement == :additional
      1 # calculate bag ccapacity here
    else
      1
    end
  end

  def placement_usage(placement)
    Array(@character.placements[placement]).size
  end

  def equip!(inventory, placement)
    placement = placement.to_sym

    return unless inventory.placements.include?(placement)

    if enough_room?(placement) and inventory.amount_available_for_equipment > 0
      Inventory.transaction do
        inventory.increment!(:equipped)

        @character.placements[placement] ||= []
        @character.placements[placement] << inventory.id
        
        @character.save!
      end
    end
  end

  def unequip!(inventory, placement = nil)
    if placement
      placement = placement.to_sym

      return unless inventory.placements.include?(placement)

      Inventory.transaction do
        inventory.decrement!(:equipped)

        if @character.placements[placement]
          @character.placements[placement].delete(inventory.id)
          
          @character.save!
        end
      end
    else
      Inventory.transaction do
        count = 0

        @character.placements.each do |placement, ids|
          count += ids.count(inventory.id)
          
          ids.delete(inventory.id)
        end

        inventory.decrease!(:equipped, count)
        
        @character.save!
      end
    end
  end
end