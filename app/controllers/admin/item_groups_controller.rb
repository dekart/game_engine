class Admin::ItemGroupsController < ApplicationController
  layout "layouts/admin/application"

  def index
    @groups = ItemGroup.all(:order => :position)
  end

  def new
    @group = ItemGroup.new
  end

  def create
    @group = ItemGroup.new(params[:item_group])

    if @group.save
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    @group = ItemGroup.find(params[:id])
  end

  def update
    @group = ItemGroup.find(params[:id])

    if @group.update_attributes(params[:item_group])
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def destroy
    @group = ItemGroup.find(params[:id])

    @group.destroy

    redirect_to :action => :index
  end

  def move
    @group = ItemGroup.find(params[:id])

    case params[:direction]
    when "up"
      @group.move_higher
    when "down"
      @group.move_lower
    end

    redirect_to :action => :index
  end
end
