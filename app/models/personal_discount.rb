class PersonalDiscount < ActiveRecord::Base
  belongs_to :character
  belongs_to :item
  
  named_scope :not_expired, Proc.new{
    {
      :conditions => ["available_till > ?", Time.now.utc]
    }
  }
  
  state_machine :initial => :active do
    state :active
    state :used

    event :use do
      transition :active => :used
    end
  end
  
  validates_presence_of :character, :item, :price, :available_till
  
  def percentage
    100 - (price.to_f / item.vip_price * 100).round
  end
end
