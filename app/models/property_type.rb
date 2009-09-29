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

  serialize :requirements, Requirements::Collection

  validates_presence_of :name, :availability, :basic_price, :income
  validates_numericality_of :basic_price, :vip_price, :income, :purchase_limit, :allow_nil => true

  def basic_price
    self[:basic_price].to_i
  end

  def vip_price
    self[:vip_price].to_i
  end

  def requirements
    super || Requirements::Collection.new
  end

  def requirements=(collection)
    unless collection.is_a?(Requirements::Collection)
      items = collection.values.collect do |requirement|
        Requirements::Base.by_name(requirement[:type]).new(requirement)
      end

      collection = Requirements::Collection.new(*items)
    end

    super(collection)
  end
end
