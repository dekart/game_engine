class Inventory
  def initialize(character)
    @character = character
  end

  def items
    load! unless @items

    @items
  end

  def give(item_alias, amount = 1)
    item = alias_to_item(item_alias)

    items[item.alias] += amount
  end

  def take(item_alias, amount = 1)
    item = alias_to_item(item_alias)

    items[item.alias] -= amount
    items[item.alias] = 0 if items[item.alias] < 0
  end

  protected

  def load!
    @items = @character[:inventory].present? ? Marshal.load(@character[:inventory]) : Hash.new(0)
  end

  def alias_to_item(item_alias)
    if item_alias.is_a?(Item)
      item_alias
    elsif item_alias.is_a?(String) or item_alias.is_a?(Symbol)
      Item[item_alias]
    else
      Item.find(item_alias)
    end
  end
end