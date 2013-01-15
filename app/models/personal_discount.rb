class PersonalDiscount < ActiveRecord::Base
  belongs_to :character
  belongs_to :item
  
  scope :not_expired, Proc.new {
    {
      :conditions => ["available_till > ?", Time.now.utc]
    }
  }
  scope :created_recently, Proc.new {
    {
      :conditions => ["personal_discounts.available_till > ?", 
        (Setting.i(:personal_discount_period).hours - Setting.i(:personal_discount_time_frame).minutes).ago.utc
      ]
    }
  }
  
  state_machine :initial => :active do
    state :active
    
    state :used do
      validate :enough_money
    end

    event :use do
      transition :active => :used
    end
    
    after_transition :active => :used, :do => [:charge_money, :give_item]
  end
  
  validates_presence_of :character, :item, :price, :available_till
  
  attr_reader :inventory
  
  def percentage
    100 - (price.to_f / item.vip_price * 100).round
  end
  
  def time_left
    (available_till - Time.now).to_i
  end
  
  def requirements
    @requirements ||= Requirements::Collection.new(
      Requirements::BasicMoney.new(:value => item.basic_price),
      Requirements::VipMoney.new(:value => price)
    )
  end

  protected
  
  def enough_money
    errors.add(:character, :not_enough_basic_money, :name => item.name) if character.basic_money < item.basic_price
    errors.add(:character, :not_enough_vip_money, :name => item.name)   if character.vip_money < price
  end
  
  def charge_money
    character.charge!(item.basic_price, price, [:personal_discount, item.id])
  end
  
  def give_item
    @inventory = character.inventories.give!(item)
  end
end
