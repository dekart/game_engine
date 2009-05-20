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

  def placements
    @placements ||= (self[:placements].blank? ? [] : self[:placements].split(","))
  end

  def placeable?
    self.placements.any?
  end
end
