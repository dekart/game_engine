class GiftsController < ApplicationController
  landing_page :gifts, :only => :new
  skip_landing_redirect :only => [:new, :show]
  
  def new
    @gift = Gift.new
    
    @items = fetch_items

    redirect_from_iframe root_url(:canvas => true) if @items.empty?
  end
  
  def success
    render :layout => 'ajax'
  end
  
  def index
    @gifts = Gift.with_state(:pending).for_character(current_character).all(:order => "sender_id, created_at DESC")
  end
  
  def update
    @gift = Gift.with_state(:pending).for_character(current_character).find(params[:id])
    
    @gift.accept
    
    render :layout => 'ajax'
  end

  protected

  def fetch_items
    Item.with_state(:visible).available.available_in(:gift).available_for(current_character).all(
      :order => "items.level DESC",
      :limit => Setting.i(:gifting_item_show_limit)
    )
  end
end
