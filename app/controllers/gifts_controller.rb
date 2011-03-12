class GiftsController < ApplicationController
  landing_page :gifts, :only => :new
  skip_landing_redirect :only => [:new, :show]
  
  def new
    @items = Item.with_state(:visible).available.available_in(:gift).available_for(current_character).all(
      :order => "items.level DESC",
      :limit => Setting.i(:gifting_item_show_limit)
    )

    redirect_from_iframe root_url(:canvas => true) if @items.empty?
  end
end
