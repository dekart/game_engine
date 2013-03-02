class InventoriesController < ApplicationController
  before_filter :check_auto_equipment, :only => [:equipment, :equip, :unequip]

  def create
    @item = GameData::Item[params[:item_id]]
    @amount = params[:amount].to_i

    @result = current_character.buy_item!(@item, @amount)
  end

  def destroy
    @amount = params[:amount].to_i
    @item = Item.find(params[:id])

    available_amount = current_character.inventories.count(@item)
    @amount = available_amount > @amount ? @amount : available_amount

    @inventory = current_character.inventories.sell!(@item, @amount)
  end

  def index
    @item_groups = ItemGroup.with_state(:visible)

    @current_group = parents.item_group || @item_groups.first

    @inventories = current_character.inventories.by_item_group(@current_group)

    if request.xhr?
      render(
        :partial => "list",
        :locals => {:inventories => @inventories},
        :layout => false
      )
    end
  end

  def use
    @amount = params[:amount] ? params[:amount].to_i : 1
    @item = Item[params[:id]]

    @inventory = current_character.inventories.find_by_item(@item)

    if @inventory
      @result = @inventory.use!(current_character, @amount)
    end

    respond_to do |format|
      format.js
    end
  end

  def equipment
  end

  def equip
    if params[:id]
      @inventory = current_character.inventories.find_by_item_id(params[:id])

      current_character.equipment.equip!(@inventory.item, params[:placement])
    else
      current_character.equipment.equip_best!
    end
  end

  def unequip
    if params[:id]
      @inventory = current_character.inventories.find_by_item_id(params[:id])

      current_character.equipment.unequip!(@inventory.item, params[:placement])
    else
      current_character.equipment.unequip_all!
    end

    render :action => "equip"
  end

  def move
    @inventory = current_character.inventories.find_by_item_id(params[:id])

    # TODO: refactor to one action from equipment
    current_character.equipment.unequip!(@inventory.item, params[:from_placement])
    current_character.equipment.equip!(@inventory.item, params[:to_placement])

    render :action => "equip"
  end

  def give
    data = encryptor.decrypt(params[:request_data].to_s)

    if Time.now < data[:valid_till]
      @character = Character.find(data[:character_id])

      if @character == current_character
        redirect_to root_url
      elsif request.get?
        @inventories = current_character.inventories.by_item_ids(data[:items]) # check string/int
      else
        @inventories = current_character.inventories.by_item_ids(data[:items])

        Character::Equipment.transaction do
          given = []

          @inventories.each do |inventory|
            if amount = params[:amount][inventory.item_id.to_s].to_i and amount > 0
              current_character.inventories.transfer!(@character, inventory.item, amount)

              given << [inventory.item_id, amount]
            end
          end

          @character.news.add(:item_transfer, :sender_id => current_character.id, :items => given) unless given.empty?
        end

        flash[:success] = t('inventories.give.messages.success')

        redirect_to root_url
      end
    else
      flash[:error] = t('inventories.give.messages.expired')

      redirect_to root_url
    end
  end

  def toggle_boost
    @destination = params[:destination]

    if @boost = current_character.boosts.by_item(Item.find(params[:id]))
      current_character.toggle_boost!(@boost.item, @destination)
    end
  end

  protected

  def check_auto_equipment
    redirect_to inventories_url if Setting.b(:character_auto_equipment)
  end

end
