class Admin::MissionsController < Admin::BaseController
  def index
    @missions = Mission.without_state(:deleted).all(
      :include  => :mission_group,
      :order    => "mission_groups.level"
    ).paginate(:page => params[:page])
  end

  def balance
    @missions = Mission.all(
      :include  => :mission_group,
      :order    => "mission_groups.level"
    )
  end

  def new
    redirect_to new_admin_mission_group_path if MissionGroup.count == 0

    @mission = Mission.new

    if params[:mission]
      @mission.attributes = params[:mission]

      @mission.valid?
    end
  end

  def create
    @mission = Mission.new(params[:mission])

    if @mission.save
      redirect_to admin_missions_url(:canvas => true)
    else
      redirect_to new_admin_mission_url(:mission => params[:mission], :canvas => true)
    end
  end

  def edit
    @mission = Mission.find(params[:id])

    if params[:mission]
      @mission.attributes = params[:mission]

      @mission.valid?
    end
  end

  def update
    @mission = Mission.find(params[:id])

    if @mission.update_attributes(params[:mission].reverse_merge(:requirements => nil, :payouts => nil))
      redirect_to admin_missions_url(:canvas => true)
    else
      redirect_to edit_admin_mission_url(:mission => params[:mission], :canvas => true)
    end
  end

  def publish
    @mission = Mission.find(params[:id])

    @mission.publish if @mission.can_publish?

    redirect_to admin_missions_path
  end

  def hide
    @mission = Mission.find(params[:id])

    @mission.hide if @mission.can_hide?

    redirect_to admin_missions_path
  end

  def destroy
    @mission = Mission.find(params[:id])

    @mission.mark_deleted if @mission.can_mark_deleted?

    redirect_to admin_missions_path
  end
end
