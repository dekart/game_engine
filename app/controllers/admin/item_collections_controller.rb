class Admin::ItemCollectionsController < Admin::BaseController
  def index
    @item_collections = ItemCollection.without_state(:deleted).all
  end

  def new
    @item_collection = ItemCollection.new
  end

  def add_item
    @item = Item.new
  end

  def create
    @item_collection = ItemCollection.new(params[:item_collection])

    if @item_collection.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_item_collections_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @item_collection = ItemCollection.find(params[:id])
  end

  def update
    @item_collection = ItemCollection.find(params[:id])

    if @item_collection.update_attributes(params[:item_collection])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_item_collections_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(ItemCollection.find(params[:id]))
  end
end
