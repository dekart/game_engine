class BankDeposit < BankOperation
  before_create :move_money

  validate :validate_enough_amount, :on => :create

  protected

  def validate_enough_amount
    errors.add(:amount, :not_enough) if amount && amount > character.basic_money
  end

  def move_money
    character.bank += amount - Setting.p(:bank_deposit_fee, amount).ceil

    character.charge!(amount, 0, :bank_deposit)
  end
end
