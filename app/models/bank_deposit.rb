class BankDeposit < BankOperation
  before_save :move_money

  protected

  def validate_on_create
    self.errors.add(:amount, :not_enough) if self.amount > self.character.basic_money
  end

  def move_money
    self.character.basic_money -= self.amount
    self.character.bank += (self.amount * 0.9).ceil
    self.character.save
  end
end
