class BankOperationsController < ApplicationController
  def new
    @deposit = BankDeposit.new(:amount => current_character.basic_money)

    @withdrawal = BankWithdraw.new

    render :new, :layout => 'ajax'
  end

  def deposit
    @deposit = current_character.bank_deposits.build(params[:bank_operation])

    if @deposit.save
      EventLoggingService.log_event(bank_event_data(:bank_deposit, @deposit))

      current_character.reload

      render :deposit, :layout => 'ajax'
    else
      render :new, :layout => 'ajax'
    end
  end

  def withdraw
    @withdrawal = current_character.bank_withdrawals.build(params[:bank_operation])

    if @withdrawal.save
      EventLoggingService.log_event(bank_event_data(:bank_withdraw, @withdrawal))

      current_character.reload

      render :withdraw, :layout => 'ajax'
    else
      render :new, :layout => 'ajax'
    end
  end

  protected

  def bank_event_data(event_type, operation)
    {
      :event_type => event_type,
      :character_id => operation.character.id,
      :level => operation.character.level,
      :basic_money => operation.amount,
      :occurred_at => Time.now
    }.to_json
  end
end
