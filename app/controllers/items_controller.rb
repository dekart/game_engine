class ItemsController < ApplicationController
  def index
    @items = Item.available_for(current_character)
  end
end
