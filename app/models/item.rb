class Item < ActiveRecord::Base
  extend HasPayouts
  include HasVisibility

  AVAILABILITIES = [:shop, :special, :loot, :mission, :gift]
  EFFECTS = [:attack, :defence, :health, :energy, :stamina]

  belongs_to  :item_group
  has_many    :inventories, :dependent => :destroy

  named_scope :available, Proc.new{
    {
      :conditions => [%{
          (
            items.available_till IS NULL OR
            items.available_till > ?
          ) AND (
            items.limit IS NULL OR
            items.limit > items.owned
          )
        },
        Time.now
      ]
    }
  }

  named_scope :available_by_level, Proc.new {|character|
    {
      :conditions => ["items.level <= ?", character.level],
      :order      => :basic_price
    }
  }

  named_scope :available_in, Proc.new{|*keys|
    valid_keys = keys.collect{|k| k.to_sym } & AVAILABILITIES # Find intersections between passed key list and available keys

    if valid_keys.any?
      valid_keys.collect!{|k| k.to_s }
      
      {:conditions => ["items.availability IN (?)", valid_keys]}
    else
      {}
    end
  }
  named_scope :next_for, Proc.new{|character|
    {
      :conditions => ["items.level > ?", character.level],
      :order      => "items.level"
    }
  }

  named_scope :vip, {:conditions => "items.vip_price > 0"}
  named_scope :basic, {:conditions => "items.vip_price IS NULL or items.vip_price = 0"}

  state_machine :initial => :hidden do
    state :hidden
    state :visible
    state :deleted

    event :publish do
      transition :hidden => :visible
    end

    event :hide do
      transition :visible => :hidden
    end

    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
  end

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "72x72#",
      :medium => "120x120#",
      :large  => "200x200#"
    }

  has_payouts :use

  validates_presence_of :name, :item_group, :availability, :level
  validates_numericality_of :level, :basic_price, :vip_price, :allow_blank => true

  class << self
    def to_grouped_dropdown
      returning result = {} do
        ItemGroup.without_state(:deleted).all(:order => :position).each do |group|
          result[group.name] = group.items.without_state(:deleted).collect{|i|
            ["%s (%s)" % [i.name, i.availability], i.id]
          }
        end
      end
    end

    def available_for(character)
      visible_for(character).available_by_level(character)
    end
  end

  (Item::EFFECTS + %w{basic_price vip_price}).each do |attribute|
    define_method(attribute) do
      self[attribute].to_i
    end
  end

  def has_price?
    basic_price > 0 or vip_price > 0
  end

  def availability
    self[:availability].to_sym
  end

  def left
    limit.to_i > 0 ? limit - owned : nil
  end

  def time_left
    (available_till - Time.now).to_i
  end

  def plural_name
    self[:plural_name].blank? ? name.pluralize : self[:plural_name]
  end

  def placements
    self[:placements].to_s.split(",").collect{|p| p.to_sym }
  end

  def placements=(value)
    value = value.to_s.split(",") unless value.is_a?(Array)

    self[:placements] = value.any? ? value.join(",") : nil
    self[:equippable] = self[:placements].present?
  end

  def placement_options_for_select
    placements.collect{|p|
      [Character::Equipment.placement_name(p), p]
    }
  end
end
