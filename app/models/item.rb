class Item < ActiveRecord::Base
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
    { :conditions => ["level <= ?", character.level], :order => :basic_price }
  }

  TYPES = %w{weapons armors potions}

  TYPES.each do |type|
    named_scope type, { :conditions => ["type = ?", type.classify] }
  end

  named_scope :shop, {:conditions => "availability = 'shop'"}

  def placements
    @placements ||= (self[:placements].blank? ? [] : self[:placements].split(","))
  end

  def placeable?
    self.placements.any?
  end
end
