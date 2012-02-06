class InventoriesController < ApplicationController
  before_filter :check_auto_equipment, :only => [:equipment, :equip, :unequip]

  def create
    @item = Item.purchaseable_for(current_character).find(params[:item_id])

    @inventory = current_character.inventories.buy!(@item, params[:amount].to_i)

    @amount = params[:amount].to_i * @item.package_size
  end

  def destroy
    @amount = params[:amount].to_i

    @item = Item.find(params[:id])

    @inventory = current_character.inventories.sell!(@item, @amount)
  end

  def index
    @inventories = current_character.inventories
    
    respond_to do |format|
      format.html
      format.js
    end
  end

  def use
    if @inventory = current_character.inventories.find_by_id(params[:id])
      @result = @inventory.use!
    end
  end

  def equipment
  end

  def equip
    if params[:id]
      @inventory = current_character.inventories.find(params[:id])
      equipped = @inventory.equipped

      current_character.equipment.equip!(@inventory, params[:placement])
    else
      placements = current_character.placements.clone
      current_character.equipment.equip_best!
    end
  end

  def unequip
    if params[:id]
      @inventory = current_character.inventories.find(params[:id])

      current_character.equipment.unequip!(@inventory, params[:placement])
    else
      placements = current_character.placements.clone
      current_character.equipment.unequip_all!
    end

    render :action => "equip"
  end
  
  def move
    @inventory = current_character.inventories.find(params[:id])
    
    # TODO: refactor to one action from equipment
    current_character.equipment.unequip!(@inventory, params[:from_placement])
    current_character.equipment.equip!(@inventory, params[:to_placement])
    
    render :action => "equip"
  end

  def give
    data = encryptor.decrypt(params[:request_data].to_s)

    if Time.now < data[:valid_till]
      @character = Character.find(data[:character_id])

      if @character == current_character
        redirect_from_iframe root_url(:canvas => true)
      elsif request.get?
        @inventories = current_character.inventories.find_all_by_item_id(data[:items])
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

        flash[:success] = t('inventories.give.messages.success')

        # TODO Refactor this to use AJAX instead of redirects
        redirect_from_iframe root_url(:canvas => true)
      end
    else
      flash[:error] = t('inventories.give.messages.expired')

      redirect_from_iframe root_url(:canvas => true)
    end
  end
  
  def toggle_boost
    @destination = params[:destination]
    @boost = current_character.boosts.inventories.find(params[:id])
    
    current_character.toggle_boost!(@boost, @destination)
  end

  protected

  def check_auto_equipment
    redirect_from_iframe inventories_url(:canvas => true) if Setting.b(:character_auto_equipment)
  end

end
