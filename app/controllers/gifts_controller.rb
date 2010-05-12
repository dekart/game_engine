class GiftsController < ApplicationController
  def new
    current_user.gift_page_visited!

    @gift ||= Gift.new
    
    @items = Item.with_state(:visible).available.available_in(:gift).available_for(current_character).all(
      :order => "items.level DESC",
      :limit => Setting.i(:gifting_item_show_limit)
    )

    if @items.any?
      render :action => :new
    else
      redirect_to landing_url
    end
  end

  def edit
    @gift = Gift.find(params[:id])

    new
  end

  def create
    unless @gift
      item = Item.find_by_id(params[:item_id])

      @gift = current_character.gifts.create(:item => item)
    end

    @group = params[:group] ? params[:group].to_sym : :all
    
    case @group
    when :players
      @exclude_ids = params["friend_ids"].split(",").collect{|id| id.to_i } - current_character.friend_relations.facebook_ids
    when :non_players
      @exclude_ids = current_character.friend_relations.facebook_ids
    else
      @exclude_ids = []
    end

    render :action => :create
  end

  def update
    @gift = Gift.find(params[:id])

    if item = Item.find_by_id(params[:item_id])
      @gift.update_attributes(:item => item)
    end

    create
  end

  def confirm
    @gift = Gift.find(params[:id])

    if params[:ids]
      if @gift.update_attributes(:recipients => params[:ids].join(","), :recipients_count => params[:ids].size)
        flash[:success] = t("gifts.confirm.messages.success")
      else
        flash[:error] = t("gifts.confirm.messages.failure")
      end
    else
      @gift.destroy
    end

    redirect_to landing_url
  end

  def show
    if params[:id] == 'all'
      @gifts = Gift.for_character(current_character)
      if @gifts.any?
        @gifts.map {|gift| gift.receipts.create(:character => current_character) }
      else
        redirect_to landing_url
      end
    elsif gift = Gift.find_by_id(params[:id]) and gift.can_receive?(current_character)
      gift_receipt = gift.receipts.create(:character => current_character)
      @gifts = [ gift ]
    else
      redirect_to landing_url
    end
  end
end
