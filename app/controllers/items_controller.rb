class ItemsController < ApplicationController
  def index
    @items = Item.available_for(current_character)
    @inventories = current_character.inventories
  end
end
