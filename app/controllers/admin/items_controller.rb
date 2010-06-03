class Admin::ItemsController < Admin::BaseController
  def index
    @item_group = ItemGroup.find_by_id(params[:item_group_id])

    @items = (@item_group ? @item_group.items : Item).without_state(:deleted).all(
      :include  => :item_group,
      :order    => "item_groups.position, items.basic_price"
    ).paginate(:page => params[:page])
  end

  def new
    redirect_to new_admin_item_group_path if ItemGroup.count == 0
    
    @item = Item.new

    if params[:item]
      @item.attributes = params[:item]
      
      @item.valid?
    end
  end

  def create
    @item = Item.new(params[:item])

    if @item.save
      redirect_to admin_items_path
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

    if @item.update_attributes(params[:item].reverse_merge(:payouts => nil))
      redirect_to admin_items_path
    else
      render :action => :edit
    end
  end

  def publish
    @item = Item.find(params[:id])

    @item.publish if @item.can_publish?

    redirect_to admin_items_path
  end

  def hide
    @item = Item.find(params[:id])

    @item.hide if @item.can_hide?

    redirect_to admin_items_path
  end

  def destroy
    @item = Item.find(params[:id])

    @item.mark_deleted if @item.can_mark_deleted?

    redirect_to admin_items_path
  end
end
