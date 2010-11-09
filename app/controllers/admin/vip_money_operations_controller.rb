class Admin::VipMoneyOperationsController < Admin::BaseController
  helper_method :operation_type, :operation_class

  def index
    scope = operation_class

    if params[:reference_type]
      scope = scope.by_reference_type(params[:reference_type])
    end

    @operations = scope.latest.paginate(:page => params[:page], :per_page => 100)
  end

  protected

  def operation_type
    params[:type] == "withdrawal" ? "withdrawal" : "deposit"
  end

  def operation_class
    "VipMoney#{operation_type.classify}".constantize
  end
end
