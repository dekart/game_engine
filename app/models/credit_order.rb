class CreditOrder < ActiveRecord::Base
  belongs_to :character
  belongs_to :package, :class_name => 'CreditPackage'

  state_machine :initial => :previewed do
    state :previewed
    state :placed
    state :settled
    state :canceled
    state :disputed
    state :refunded
    
    event :place do
      transition :previewed => :placed
    end
    
    event :settle do
      transition [:placed, :disputed] => :settled
    end
    
    event :cancel do
      transition [:previewed, :placed] => :canceled
    end
    
    event :dispute do
      transition :settled => :disputed
    end
    
    event :refund do
      transition [:settled, :disputed] => :refunded
    end
    
    after_transition :placed => :settled, :do => :deposit_vip_money
  end
  
  protected
  
  def deposit_vip_money
    character.charge!(0, - package.vip_money, :credits)
  end
end
