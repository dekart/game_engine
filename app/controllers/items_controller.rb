class ItemsController < ApplicationController
  def index
    @items = Item.shop.available_for(current_character)
  end
end
