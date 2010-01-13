class Item < ActiveRecord::Base
  extend HasEffects

  AVAILABILITIES = [:shop, :special, :loot, :mission, :gift]

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
            items.limit > owned
          )
        },
        Time.now
      ]
    }
  }
  named_scope :available_for, Proc.new {|character|
    {
      :conditions => ["level <= ?", character.level],
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

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "72x72#",
      :medium => "120x120#",
      :large  => "200x200#",
      :belt   => "84x24#"
    }

  has_effects

  validates_presence_of :name, :item_group, :availability, :level
  validates_presence_of :usage_limit, :if => :usable?
  validates_numericality_of :level, :basic_price, :vip_price, :usage_limit, :allow_blank => true

  def self.to_grouped_dropdown
    returning result = {} do
      ItemGroup.all(:order => :position).each do |group|
        result[group.name] = group.items.collect{|i| 
          ["%s (%s)" % [i.name, i.availability], i.id]
        }
      end
    end
  end

  def attack
    self[:attack].to_i
  end

  def defence
    self[:defence].to_i
  end

  def basic_price
    self[:basic_price].to_i
  end

  def vip_price
    self[:vip_price].to_i
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
    self[:plural_name].blank? ? self.name.pluralize : self[:plural_name]
  end
end
