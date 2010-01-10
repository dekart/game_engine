class PromotionReceipt < ActiveRecord::Base
  belongs_to :promotion, :counter_cache => true
  belongs_to :character

  before_create :assign_payouts

  attr_reader :payouts

  protected

  def assign_payouts
    @payouts = self.promotion.payouts.apply(self.character, :success)

    self.character.save!
  end
end
