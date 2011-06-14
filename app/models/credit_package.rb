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
  
  before_save :reset_default
  
  protected
  
  def reset_default
    if default_changed? and default?
      self.class.update_all(:default => false)
    end
  end
end
