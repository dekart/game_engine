class PropertyType < ActiveRecord::Base
  AVAILABILITIES = [:shop, :mission, :loot]

  has_many :properties, :dependent => :destroy

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x>"
    }
    
  named_scope :available_in, Proc.new{|key|
    AVAILABILITIES.include?(key.to_sym) ? {:conditions => ["availability = ?", key.to_s]} : {}
  }

  named_scope :available_for, Proc.new {|character|
    {
      :conditions => ["level <= ?", character.level],
      :order      => :basic_price
    }
  }

  validates_presence_of :name, :availability, :basic_price, :income
  validates_numericality_of :basic_price, :vip_price, :income, :purchase_limit, :allow_nil => true

  def basic_price
    self[:basic_price].to_i
  end

  def vip_price
    self[:vip_price].to_i
  end

  def inflated_price(amount)
    inflation ? basic_price + inflation * (amount - 1) : basic_price
  end
end
