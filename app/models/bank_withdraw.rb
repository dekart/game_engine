class BankWithdraw < BankOperation
  before_save :move_money

  protected

  def validate_on_create
    self.errors.add(:amount, :not_enough) if self.amount && self.amount > self.character.bank
  end

  def move_money
    self.character.basic_money  += self.amount
    self.character.bank         -= self.amount

    self.character.save
  end
end