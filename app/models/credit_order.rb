class CreditOrder < ActiveRecord::Base
  belongs_to :character
  belongs_to :package, :class_name => 'CreditPackage'

  state_machine :initial => :previewed do
    state :previewed
    state :placed
    state :canceled
    state :disputed
    state :refunded
    
    event :place do
      transition :previewed => :placed
    end
    
    event :cancel do
      transition [:previewed, :placed] => :canceled
    end
    
    event :dispute do
      transition :placed => :disputed
    end
    
    event :refund do
      transition [:placed, :disputed] => :refunded
    end
    
    after_transition :previewed => :placed, :do => :deposit_vip_money
  end
  
  validates_presence_of   :facebook_id, :character, :package
  validates_uniqueness_of :facebook_id
  
  protected
  
  def deposit_vip_money
    character.charge!(0, - package.vip_money, :credits)
  end
end
