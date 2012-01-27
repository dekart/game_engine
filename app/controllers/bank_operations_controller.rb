class BankOperationsController < ApplicationController
  def new
    @deposit = BankDeposit.new(:amount => current_character.basic_money)

    @withdrawal = BankWithdraw.new
  end

  def deposit
    @deposit = current_character.bank_deposits.build(params[:bank_operation])

    if @deposit.save
      current_character.reload
    else
      render :new
    end
  end

  def withdraw
    @withdrawal = current_character.bank_withdrawals.build(params[:bank_operation])

    if @withdrawal.save
      current_character.reload
    else
      render :new
    end
  end
end
