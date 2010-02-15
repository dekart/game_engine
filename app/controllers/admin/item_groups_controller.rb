class Admin::ItemGroupsController < Admin::BaseController
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
      redirect_to admin_item_groups_path
    else
      render :action => :edit
    end
  end

  def publish
    @group = ItemGroup.find(params[:id])

    @group.publish if @group.can_publish?

    redirect_to admin_item_groups_path
  end

  def hide
    @group = ItemGroup.find(params[:id])

    @group.hide if @group.can_hide?

    redirect_to admin_item_groups_path
  end

  def destroy
    @group = ItemGroup.find(params[:id])

    @group.mark_deleted if @group.can_mark_deleted?

    redirect_to admin_item_groups_path
  end

  def move
    @group = ItemGroup.find(params[:id])

    case params[:direction]
    when "up"
      @group.move_higher
    when "down"
      @group.move_lower
    end

    redirect_to admin_item_groups_path
  end
end
