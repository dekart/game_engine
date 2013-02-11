class ItemsController < ApplicationController
  def index
    @groups = GameData::ItemGroup.select{|g| g.tags.include?(:shop) }

    @current_group = GameData::ItemGroup[params[:item_group_id]] || @groups.first

    @items = @current_group.items.select{|i| i.in_shop_for?(current_character) }.sort{|i| [i.level, i.vip_price] }.reverse

    @locked_items = @current_group.items.select{|i| i.in_shop_and_locked_for?(current_character) }.sort{|i| i.level }[0..2]

    respond_to do |format|
      format.json do
        render :json => {
          :groups => @groups.map{|g|
            g.as_json.tap do |r|
              r[:current] = true if g == @current_group
            end
          },
          :items => @items.map{|i|
            i.as_json_for(current_character)
          } + @locked_items.map{|i| i.as_json_for(current_character).merge!(:locked => true) }
        }
      end
    end
  end

  def show
    @item = Item.find(params[:id])

    render :layout => 'ajax'
  end
end
