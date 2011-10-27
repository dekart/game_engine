class Admin::MissionLevelsController < Admin::BaseController
  def new
    @level = parents.mission.levels.build
  end

  def create
    @level = parents.mission.levels.build(params[:mission_level])

    if @level.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_missions_path
      end
    else
      render :new
    end
  end

  def edit
    @level = MissionLevel.find(params[:id])
  end

  def update
    @level = MissionLevel.find(params[:id])

    if @level.update_attributes(params[:mission_level])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_missions_path
      end
    else
      render :edit
    end
  end

  def change_position
    change_position_action(MissionLevel.find(params[:id]))
  end
end
