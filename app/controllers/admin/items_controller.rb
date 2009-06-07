class Admin::ItemsController < ApplicationController
  before_filter :admin_required
  
  layout "layouts/admin/application"

  def index
    @items = Item.all(
      :include => :item_group,
      :order => "item_groups.position, items.basic_price"
    ).paginate(:page => params[:page])
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(params[:item])

    if @item.save
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])

    if @item.update_attributes(params[:item])
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def destroy
    @item = Item.find(params[:id])

    @item.destroy

    redirect_to :action => :index
  end

  def add_effect
    @effect = Effects::Base.by_name(params[:type]).new(nil)

    render :action => :add_effect, :layout => "admin/ajax"
  end
end
