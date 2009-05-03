class BankOperationsController < ApplicationController
  def new
    @deposit = BankDeposit.new
    @withdraw = BankWithdraw.new
  end

  def create
    new

    @operation = (params[:type] == "deposit" ? @deposit : @withdraw)

    @operation.attributes = params[:bank_operation]
    @operation.character  = current_character

    @operation.save

    render :action => :new
  end
end
