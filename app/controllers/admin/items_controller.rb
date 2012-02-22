class Admin::ItemsController < Admin::BaseController
  def index
    @availability = params[:availability].try(:to_sym)
    @item_group = ItemGroup.find_by_id(params[:item_group_id])

    @scope = @item_group ? @item_group.items : Item
    @scope = @scope.available_in(@availability)

    @items = @scope.without_state(:deleted).includes(:item_group).order(
      "item_groups.position, items.availability, items.level"
    ).paginate(:page => params[:page])
  end

  def new
    redirect_to new_admin_item_group_path if ItemGroup.count == 0

    @item = Item.new
    @item.placements = Character::Equipment::DEFAULT_PLACEMENTS

    if params[:item]
      @item.attributes = params[:item]

      @item.valid?
    end
  end

  def create
    @item = Item.new(params[:item])

    if @item.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_items_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @item = Item.find(params[:id])

    if params[:item]
      @item.attributes = params[:item]

      @item.valid?
    end
  end

  def update
    @item = Item.find(params[:id])
    #FIX ME
    if @item.update_attributes(params[:item].reverse_merge(:placements => nil))
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_items_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(Item.find(params[:id]))
  end

end
