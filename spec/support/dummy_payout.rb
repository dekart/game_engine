class Payouts::DummyPayout < Payouts::Base
  attr_reader :applied, :character, :reference
  
  def apply(character, reference = nil)
    @applied = true
    @character = character
    @reference = reference
  end
end