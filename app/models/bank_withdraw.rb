class BankWithdraw < BankOperation
  before_save :move_money

  protected

  def validate_on_create
    if self.amount > self.character.bank
      self.errors.add(:amount, "You don't have that much money at your balance")
    end
  end

  def move_money
    self.character.increment(:basic_money, self.amount)
    self.character.decrement(:bank, self.amount)
    self.character.save
  end
end