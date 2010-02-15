class BankOperationsController < ApplicationController
  def new
    @deposit = BankDeposit.new
    @withdraw = BankWithdraw.new

    render :action => :new
  end

  def create
    @operation = (params[:type] == "deposit" ? BankDeposit : BankWithdraw).new(params[:bank_operation])

    @operation.character = current_character

    @operation.save

    redirect_to new_bank_operation_path
  end
end
