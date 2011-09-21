class Admin::AchievementTypesController < Admin::BaseController
  def index
    @achievement_types = AchievementType.without_state(:deleted).all
  end

  def new
    @achievement_type = AchievementType.new
  end

  def create
    @achievement_type = AchievementType.new(params[:achievement_type])

    if @achievement_type.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_achievement_types_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @achievement_type = AchievementType.find(params[:id])
  end

  def update
    @achievement_type = AchievementType.find(params[:id])

    if @achievement_type.update_attributes(params[:achievement_type])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_achievement_types_path
      end
    else
      render :action => :edit
    end
  end

  def publish
    @achievement_type = AchievementType.find(params[:id])

    @achievement_type.publish if @achievement_type.can_publish?

    redirect_to admin_achievement_types_path
  end

  def hide
    @achievement_type = AchievementType.find(params[:id])

    @achievement_type.hide if @achievement_type.can_hide?

    redirect_to admin_achievement_types_path
  end

  def destroy
    @achievement_type = AchievementType.find(params[:id])

    @achievement_type.mark_deleted

    redirect_to admin_achievement_types_path
  end
end
