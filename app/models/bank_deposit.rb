class BankDeposit < BankOperation
  before_save :move_money

  protected

  def validate_on_create
    if self.amount > self.character.basic_money
      self.errors.add(:amount, "You don't have that much cash")
    end
  end

  def move_money
    self.character.decrement(:basic_money, self.amount)
    self.character.increment(:bank, (self.amount * 0.9).ceil)
    self.character.save
  end
end
