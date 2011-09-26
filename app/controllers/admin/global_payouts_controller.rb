class Admin::GlobalPayoutsController < Admin::BaseController
  def index
    @global_payouts = GlobalPayout.all(:order => "alias")
  end

  def new
    @global_payout = GlobalPayout.new
  end

  def create
    @global_payout = GlobalPayout.new(params[:global_payout])

    if @global_payout.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_global_payouts_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @global_payout = GlobalPayout.find(params[:id])
  end

  def update
    @global_payout = GlobalPayout.find(params[:id])

    if @global_payout.update_attributes(params[:global_payout])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_global_payouts_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(GlobalPayout.find(params[:id]))
  end
end
