module ItemCollectionsHelper
  def collection_items(collection)
    collection.items.each do |item|
      inventory = current_character.inventories.find_by_item(item)

      yield(item, inventory)
    end
  end
end
