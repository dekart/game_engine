class MarketItemsController < ApplicationController
  def index
    @items = MarketItem.paginate(:page => params[:page])
  end

  def new
    @inventory = current_character.inventories.find_by_id(params[:inventory_id])
    @item = @inventory.build_market_item

    render :layout => "ajax"
  end

  def create
    @inventory = current_character.inventories.find_by_id(params[:market_item][:inventory_id])

    @item = @inventory.build_market_item(params[:market_item])

    if @item.save
      EventLoggingService.log_event(market_event_data(:market_item_created, @item))

      render :create, :layout => "ajax"
    else
      render :new, :layout => "ajax"
    end
  end

  def buy
    @item = MarketItem.find(params[:id])

    @item.buy!(current_character)

    if @item.errors.empty?
      EventLoggingService.log_event(market_event_data(:market_item_bought, @item))
    end

    render :buy, :layout => "ajax"
  end

  def destroy
    @item = current_character.market_items.find(params[:id])

    @item.destroy

    EventLoggingService.log_event(market_event_data(:market_item_destroyed, @item))

    render :destroy, :layout => "ajax"
  end

  protected

  def market_event_data(event_type, item)
    {
      :event_type => event_type,
      :character_id => item.character.id,
      :level => item.character.level,
      :reference_id => item.id,
      :reference_type => "MarketItem",
      :amount => item.amount,
      :occurred_at => Time.now
    }.to_json
  end
end
