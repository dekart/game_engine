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

  def availability
    self[:availability].to_sym
  end

  def left
    limit.to_i > 0 ? limit - owned : nil
  end

  def time_left
    (available_till - Time.now).to_i
  end
end
