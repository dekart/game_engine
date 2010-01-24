class PropertyType < ActiveRecord::Base
  AVAILABILITIES = [:shop, :mission, :loot]

  has_many :properties, :dependent => :destroy

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x>"
    }
    
  named_scope :available_in, Proc.new{|*keys|
    valid_keys = keys.collect{|k| k.to_sym } & AVAILABILITIES # Find intersections between passed key list and available keys

    if valid_keys.any?
      valid_keys.collect!{|k| k.to_s }

      {:conditions => ["property_types.availability IN (?)", valid_keys]}
    else
      {}
    end
  }

  named_scope :available_for, Proc.new {|character|
    {
      :conditions => ["level <= ?", character.level],
      :order      => :basic_price
    }
  }

  state_machine :initial => :draft do
    state :draft
    state :visible
    state :deleted

    event :publish do
      transition :draft => :visible
    end

    event :hide do
      transition :visible => :draft
    end

    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
  end

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

  def availability
    self[:availability].to_sym
  end

  def plural_name
    self[:plural_name].blank? ? self.name.pluralize : self[:plural_name]
  end
end
