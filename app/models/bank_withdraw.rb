class BankWithdraw < BankOperation
  before_create :move_money

  validate :validate_enough_amount, :on => :create

  protected

  def validate_enough_amount
    errors.add(:amount, :not_enough) if amount && amount > character.bank
  end

  def move_money
    character.bank -= amount

    character.charge!(- amount, 0, :bank_withdraw)
  end
end
