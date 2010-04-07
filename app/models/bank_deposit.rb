class BankDeposit < BankOperation
  before_save :move_money

  protected

  def validate_on_create
    self.errors.add(:amount, :not_enough) if self.amount && self.amount > self.character.basic_money
  end

  def move_money
    self.character.basic_money  -= amount
    self.character.bank         += amount - Setting.p(:bank_deposit_fee, amount).ceil
    
    self.character.save
  end
end
