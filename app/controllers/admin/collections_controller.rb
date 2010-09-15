class Admin::CollectionsController < Admin::BaseController
  def index
    @collections = Collection.without_state(:deleted).all(:order => "name ASC")
  end

  def new
    @collection = Collection.new
  end

  def add_item
    @item = Item.new
  end

  def create
    @collection = Collection.new(params[:collection])

    if @collection.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_collections_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @collection = Collection.find(params[:id])
  end

  def update
    @collection = Collection.find(params[:id])

    if @collection.update_attributes(params[:collection])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_collections_path
      end
    else
      render :action => :edit
    end
  end

  def publish
    @collection = Collection.find(params[:id])

    @collection.publish if @collection.can_publish?

    redirect_to admin_collections_path
  end

  def hide
    @collection = Collection.find(params[:id])

    @collection.hide if @collection.can_hide?

    redirect_to admin_collections_path
  end

  def destroy
    @collection = Collection.find(params[:id])

    @collection.mark_deleted

    redirect_to admin_collections_path
  end
end
