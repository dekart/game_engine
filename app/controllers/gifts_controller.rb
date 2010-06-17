class GiftsController < ApplicationController
  landing_page :gifts, :only => :new
  skip_landing_redirect :only => [:new, :show]

  def new
    @gift ||= Gift.new
    
    @items = Item.with_state(:visible).available.available_in(:gift).available_for(current_character).all(
      :order => "items.level DESC",
      :limit => Setting.i(:gifting_item_show_limit)
    )

    if @items.any?
      render :action => :new
    else
      redirect_to root_path
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

    if Setting.i(:gifting_repeat_send_delay) > 0
      @exclude_ids += current_character.gift_receipts.recent_recipient_facebook_ids(
        Setting.i(:gifting_repeat_send_delay)
      )
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

    begin
      if params[:ids]
        @gift.receipts.sent_to!(params[:ids])

        flash[:success] = t("gifts.confirm.messages.success")
      else
        @gift.destroy
      end

    rescue ActiveRecord::RecordInvalid
      flash[:error] = t("gifts.confirm.messages.failure")
    end

    redirect_to root_path
  end

  def show
    @gifts = current_character.accept_gifts(params[:id])
    
    redirect_to root_path if @gifts.empty?
  end
end
