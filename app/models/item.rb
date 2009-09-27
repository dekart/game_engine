class Item < ActiveRecord::Base
  AVAILABILITIES = [:shop, :special, :loot, :mission]

  belongs_to  :item_group
  has_many    :inventories, :dependent => :destroy

  extend SerializeWithPreload

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "72x72#",
      :medium => "120x120#",
      :large  => "200x200#",
      :belt   => "84x24#"
    }

  serialize :effects, Effects::Collection

  named_scope :available_for, Proc.new {|character|
    {
      :conditions => ["level <= ?", character.level],
      :order      => :basic_price
    }
  }
  named_scope :available_in, Proc.new{|key|
    AVAILABILITIES.include?(key.to_sym) ? {:conditions => ["availability = ?", key.to_s]} : {}
  }
  named_scope :next_for, Proc.new{|character|
    {
      :conditions => ["items.level > ?", character.level],
      :order      => "items.level"
    }
  }

  named_scope :vip, {:conditions => "vip_price > 0"}
  named_scope :basic, {:conditions => "vip_price IS NULL or vip_price = 0"}

  validates_presence_of :name, :item_group, :availability, :level, :basic_price
  validates_numericality_of :level, :basic_price, :vip_price, :usage_limit, :allow_blank => true

  def self.to_grouped_dropdown
    returning result = {} do
      ItemGroup.all(:order => :position).each do |group|
        result[group.name] = group.items.collect{|i| [i.name, i.id]}
      end
    end
  end

  def basic_price
    self[:basic_price].to_i
  end

  def vip_price
    self[:vip_price].to_i
  end

  def effects
    super || Effects::Collection.new
  end

  def effects=(collection)
    if collection and !collection.is_a?(Effects::Collection)
      items = collection.values.collect do |effect|
        Effects::Base.by_name(effect[:type]).new(effect[:value])
      end
      
      collection = Effects::Collection.new(*items)
    end

    super(collection)
  end
end
