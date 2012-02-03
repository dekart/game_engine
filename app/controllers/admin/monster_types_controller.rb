class Admin::MonsterTypesController < Admin::BaseController
  def index
    @types = MonsterType.without_state(:deleted).order(:level)
  end

  def new
    @monster_type = MonsterType.new
  end

  def create
    @monster_type = MonsterType.new(params[:monster_type])

    if @monster_type.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_monster_types_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @monster_type = MonsterType.find(params[:id])
  end

  def update
    @monster_type = MonsterType.find(params[:id])

    if @monster_type.update_attributes(params[:monster_type])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_monster_types_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(MonsterType.find(params[:id]))
  end
end
