class BankOperationsController < ApplicationController
  def new
    @deposit = BankDeposit.new(:amount => current_character.basic_money)

    @withdrawal = BankWithdraw.new

    render :new, :layout => 'ajax'
  end

  def deposit
    @deposit = current_character.bank_deposits.build(params[:bank_operation])

    if @deposit.save
      EventLoggingService.log_event(:bank_deposit, @deposit)

      current_character.reload

      render :deposit, :layout => 'ajax'
    else
      render :new, :layout => 'ajax'
    end
  end

  def withdraw
    @withdrawal = current_character.bank_withdrawals.build(params[:bank_operation])

    if @withdrawal.save
      EventLoggingService.log_event(:bank_withdraw, @withdrawal)

      current_character.reload

      render :withdraw, :layout => 'ajax'
    else
      render :new, :layout => 'ajax'
    end
  end
  
end
