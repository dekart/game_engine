class Item < ActiveRecord::Base
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

  named_scope :shop, {:conditions => "availability = 'shop'"}

  validates_presence_of :name, :item_group, :availability, :level, :basic_price
  validates_numericality_of :level, :basic_price, :vip_price, :usage_limit, :allow_blank => true

  def placements
    @placements ||= (self[:placements].blank? ? [] : self[:placements].split(","))
  end

  def placements=(value)
    self[:placements] = value.is_a?(Array) ? value.join(",") : value
  end

  def placeable?
    self.placements.any?
  end

  def effect_params=(collection)
    items = collection.values.collect do |effect|
      Effects::Base.by_name(effect[:type]).new(effect[:value].to_i)
    end

    self.effects = Effects::Collection.new(*items)
  end
end
