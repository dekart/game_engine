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
      transition :placed => :settled
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
  end
end
