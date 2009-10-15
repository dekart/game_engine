class GiftsController < ApplicationController
  def new
    current_user.gift_page_visited!
    
    @items = Item.available_in(:gift).available_for(current_character).all(
      :order => "items.level DESC",
      :limit => Configuration[:gifting_item_show_limit]
    )
  end

  def edit
    @gift = Gift.find(params[:id])

    @items = Item.available_in(:gift).available_for(current_character).all(
      :order => "items.level DESC",
      :limit => Configuration[:gifting_item_show_limit]
    )

    render :action => :new
  end

  def create
    item = Item.find_by_id(params[:item_id])

    if params[:gift_id]
      @gift = Gift.find(params[:gift_id])

      @gift.update_attributes(:item => item) if item
    else
      @gift = current_character.gifts.create(:item => item)
    end

    @group = params[:group] ? params[:group].to_sym : :all
    
    case @group
    when :all
      @exclude_ids = []
    when :players
      @exclude_ids = facebook_params["friends"].collect{|id| id.to_i } - current_character.friend_relations.facebook_ids
    when :non_players
      @exclude_ids = current_character.friend_relations.facebook_ids
    end
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

    redirect_to root_path
  end

  def show
    if @gift = Gift.find_by_id(params[:id]) and @gift.can_receive?(current_character)
      @gift_receipt = @gift.receipts.create(:character => current_character)
    else
      redirect_to root_path
    end
  end
end
