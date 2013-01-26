class Admin::VipMoneyOperationsController < Admin::BaseController
  helper_method :operation_type, :operation_class

  def index
    scope = operation_class
    scope = scope.by_reference_type(params[:reference_type]) unless params[:reference_type].blank?
    scope = scope.by_profile_ids(params[:profile_ids].split(/[^\d]+/)) unless params[:profile_ids].blank?

    @operations = scope.latest.paginate(:page => params[:page], :per_page => 100)
  end

  def report
    @character = Character.find(params[:id])

    @operations = VipMoneyOperation.where(:character_id => @character.id).order("id desc").all

    @summary = {
      :total => @operations.size,
      :deposits => @operations.count{|o| o.is_a?(VipMoneyDeposit) },
      :withdrawals => @operations.count{|o| o.is_a?(VipMoneyWithdrawal) },
      :payments => @operations.count{|o| VipMoneyDeposit::PAYMENT_PROVIDERS.include?(o.reference) },
      :purchased => @operations.sum{|o|
        VipMoneyDeposit::PAYMENT_PROVIDERS.include?(o.reference) ? o.amount : 0
      }
    }
  end

  protected

  def operation_type
    params[:type] == "withdrawal" ? "withdrawal" : "deposit"
  end

  def operation_class
    "VipMoney#{operation_type.camelize}".constantize
  end
end
