class CreditPackage < ActiveRecord::Base
  default_scope :order => "vip_money"

  state_machine :initial => :hidden do
    state :hidden
    state :visible
    state :deleted

    event :publish do
      transition :hidden => :visible
    end

    event :hide do
      transition :visible => :hidden
    end

    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
  end
  
  has_attached_file :image

  validates_presence_of :vip_money, :price
  validates_numericality_of :vip_money, :price, :allow_blank => true, :greater_than => 0
  
  after_save :reset_default

  def discount
    first = self.class.with_state(:visible).first

    vip_proportion = vip_money.to_f / first.vip_money
    full_price = vip_proportion * first.price

    if full_price > price
      ((full_price - price) / full_price * 100).round
    end
  end
  
  protected
  
  def reset_default
    self.class.update_all({:default => false}, ['id != ?', self.id]) if default?
  end
end
