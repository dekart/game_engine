class Admin::CreditPackagesController < Admin::BaseController
  def index
    @packages = CreditPackage.without_state(:deleted)
  end

  def new
    @package = CreditPackage.new
  end

  def create
    @package = CreditPackage.new(params[:credit_package])

    if @package.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_credit_packages_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @package = CreditPackage.find(params[:id])
  end

  def update
    @package = CreditPackage.find(params[:id])

    if @package.update_attributes(params[:credit_package])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_credit_packages_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(CreditPackage.find(params[:id]))
  end
end
