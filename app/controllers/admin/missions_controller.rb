class Admin::MissionsController < Admin::BaseController
  def index
    @missions = Mission.without_state(:deleted).all(
      :include  => :mission_group,
      :order    => "mission_groups.position, mission_groups.id, missions.position"
    )
  end

  def balance
    @character_types = CharacterType.without_state(:deleted)

    @character_type = @character_types.find_by_id(params[:character_type_id]) || @character_types.first

    @missions = Mission.without_state(:deleted).visible_for(@character_type).all(
      :include  => :mission_group,
      :order    => "mission_groups.position"
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
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to new_polymorphic_path([:admin, @mission, MissionLevel])
      end
    else
      render :action => :new
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

    if @mission.update_attributes(params[:mission])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to(
          @mission.levels.size > 0 ? admin_missions_path : new_polymorphic_path([:admin, @mission, MissionLevel])
        )
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(Mission.find(params[:id]))
  end

  def change_position
    change_position_action(Mission.find(params[:id]))
  end
end
