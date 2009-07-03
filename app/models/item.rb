class Item < ActiveRecord::Base
  AVAILABILITIES = [:shop, :loot, :quest]

  belongs_to :item_group

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

  def placements
    @placements ||= (self[:placements].blank? ? [] : self[:placements].split(","))
  end

  def placements=(value)
    self[:placements] = value.is_a?(Array) ? value.join(",") : value
  end

  def placeable?
    self.placements.any?
  end

  def effects
    super || Effects::Collection.new
  end

  def effects=(collection)
    unless collection.is_a?(Effects::Collection)
      items = collection.values.collect do |effect|
        Effects::Base.by_name(effect[:type]).new(effect[:value])
      end
      
      collection = Effects::Collection.new(*items)
    end

    super(collection)
  end
end
