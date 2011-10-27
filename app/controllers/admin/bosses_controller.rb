class Admin::BossesController < Admin::BaseController
  def index
    @bosses = Boss.without_state(:deleted).paginate(:page => params[:page])
  end

  def new
    redirect_to new_admin_boss_group_path if MissionGroup.count == 0

    @boss = Boss.new

    if params[:boss]
      @boss.attributes = params[:boss]

      @boss.valid?
    end
  end

  def create
    @boss = Boss.new(params[:boss])

    if @boss.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_bosses_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @boss = Boss.find(params[:id])

    if params[:boss]
      @boss.attributes = params[:boss]

      @boss.valid?
    end
  end

  def update
    @boss = Boss.find(params[:id])

    if @boss.update_attributes(params[:boss])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_bosses_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(Boss.find(params[:id]))
  end
end
