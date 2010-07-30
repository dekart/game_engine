class Admin::VipMoneyOperationsController < Admin::BaseController
  helper_method :operation_type
  
  def index
    @operations = operation_class.latest.paginate(:page => params[:page], :per_page => 100)
  end

  protected

  def operation_type
    params[:type] == "withdrawal" ? "withdrawal" : "deposit"
  end

  def operation_class
    "VipMoney#{operation_type.classify}".constantize
  end
end
