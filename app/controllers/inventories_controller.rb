class InventoriesController < ApplicationController
  before_filter :check_auto_equipment, :only => [:equipment, :equip, :unequip]

  def new
    @item = Item.purchaseable_for(current_character).find_by_id(params[:item_id])
    @amount = params[:amount].to_i

    render :action => :new, :layout => "ajax"
  end

  def create
    @item = Item.purchaseable_for(current_character).find(params[:item_id])

    @inventory = current_character.inventories.buy!(@item, params[:amount].to_i)

    @amount = params[:amount].to_i * @item.package_size

    EventLoggingService.log_event(:item_bought, current_character, @item, @amount)

    render :action => :create, :layout => "ajax"
  end

  def destroy
    @amount = params[:amount].to_i

    @item = Item.find(params[:id])

    @inventory = current_character.inventories.sell!(@item, @amount)

    if @inventory 
      EventLoggingService.log_event(:item_sold, current_character, @inventory, @amount)
    end

    render :action => :destroy, :layout => "ajax"
  end

  def index
    @inventories = current_character.inventories
  end

  def use
    @inventory = current_character.inventories.find(params[:id])

    @result = @inventory.use!

    render :action => :use, :layout => "ajax"
  end

  def equipment

  end

  def equip
    if params[:id]
      @inventory = current_character.inventories.find(params[:id])
      equipped = @inventory.equipped

      current_character.equipment.equip!(@inventory, params[:placement])

      if @inventory.equipped == equipped + 1
        EventLoggingService.log_event(:item_equipped, @inventory, params[:placement])
      end
    else
      placements = current_character.placements.clone
      current_character.equipment.equip_best!

      if placements != current_character.placements
        EventLoggingService.log_event(:all_equipped, current_character)
      end
    end

    render :layout => "ajax"
  end

  def unequip
    if params[:id]
      @inventory = current_character.inventories.find(params[:id])

      current_character.equipment.unequip!(@inventory, params[:placement])

      EventLoggingService.log_event(:item_unequipped, @inventory, params[:placement])
    else
      placements = current_character.placements.clone
      current_character.equipment.unequip_all!

      if placements != current_character.placements
        EventLoggingService.log_event(:all_unequipped, current_character)
      end
    end

    render :action => "equip", :layout => "ajax"
  end

  def give
    data = encryptor.decrypt(params[:request_data].to_s)

    if Time.now < data[:valid_till]
      @character = Character.find(data[:character_id])

      if @character == current_character
        redirect_from_iframe root_url(:canvas => true)
      elsif request.get?
        @inventories = current_character.inventories.find_all_by_item_id(data[:items])

        if @inventories.empty?
          flash[:error] = t('inventories.give.messages.no_items')

          redirect_from_iframe root_url(:canvas => true)
        end
      else
        @inventories = current_character.inventories.all(
          :conditions => {
            :item_id => data[:items],
            :id => params[:inventory].keys
          }
        )

        Inventory.transaction do
          given = []
          
          @inventories.each do |inventory|
            if amount = params[:inventory][inventory.id.to_s].to_i and amount > 0
              current_character.inventories.transfer!(@character, inventory, amount)
              
              given << [inventory.item_id, amount]
            end
          end
          
          @character.news.add(:item_transfer, :sender_id => current_character.id, :items => given) unless given.empty?
        end

        @inventories.each do |inventory|
          EventLoggingService.log_event(:item_given, current_character, @character, inventory.item)
        end

        flash[:success] = t('inventories.give.messages.success')

        # TODO Refactor this to use AJAX instead of redirects
        redirect_from_iframe root_url(:canvas => true)
      end
    else
      flash[:error] = t('inventories.give.messages.expired')

      redirect_from_iframe root_url(:canvas => true)
    end
  end

  protected

  def check_auto_equipment
    redirect_from_iframe inventories_url(:canvas => true) if Setting.b(:character_auto_equipment)
  end

end
