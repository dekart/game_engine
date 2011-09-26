class Admin::TipsController < Admin::BaseController
  def index
    @tips = Tip.without_state(:deleted).paginate(:page => params[:page])
  end

  def new
    @tip = Tip.new
  end

  def create
    @tip = Tip.new(params[:tip])

    if @tip.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_tips_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @tip = Tip.find(params[:id])
  end

  def update
    @tip = Tip.find(params[:id])

    if @tip.update_attributes(params[:tip])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_tips_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(Tip.find(params[:id]))
  end
end
