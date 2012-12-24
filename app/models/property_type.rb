class PropertyType < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements
  extend HasPictures
  include HasVisibility

  AVAILABILITIES = [:shop, :mission, :loot]

  has_many :properties, :dependent => :destroy

  has_requirements

  has_payouts :build, :upgrade, :collect

  has_pictures :styles => [
    [:medium, "180x180>"],
    [:small,  "120x120>"],
    [:stream, "90x90#"],
    [:icon,   "50x50>"]
  ]

  scope :available_in, Proc.new{|*keys|
    valid_keys = keys.collect{|k| k.to_sym } & AVAILABILITIES # Find intersections between passed key list and available keys

    if valid_keys.any?
      valid_keys.collect!{|k| k.to_s }

      {:conditions => ["property_types.availability IN (?)", valid_keys]}
    else
      {}
    end
  }

  scope :available_by_level, Proc.new {|character|
    {
      :conditions => ["level <= ?", character.level],
      :order      => :basic_price
    }
  }

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

  validates_presence_of :name, :availability, :basic_price, :income, :income_by_level
  validates_numericality_of :basic_price, :vip_price, :income, :upgrade_limit, :income_by_level,
    :allow_nil => true

  class << self
    def to_dropdown(*args)
      without_state(:deleted).all(:order => :name).to_dropdown(*args)
    end

    def available_for(character)
      visible_for(character).available_by_level(character)
    end
  end

  def upgradeable?
    (upgrade_limit || Setting.i(:property_upgrade_limit)) > 1
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

  def plural_name
    self[:plural_name].blank? ? name.pluralize : self[:plural_name]
  end

  def description
    self[:description].to_s.html_safe
  end

  def worker_names
    self[:worker_names].split(/[\n,]/).map{|n| n.strip }
  end

  def upgrade_price(level)
    upgrade_cost_increase ? basic_price + upgrade_cost_increase * level : basic_price
  end

  def default_requirements
    @requirements ||= Requirements::Collection.new.tap do |r|
      r << Requirements::BasicMoney.new(:value => basic_price) if basic_price > 0
      r << Requirements::VipMoney.new(:value => vip_price) if vip_price > 0
      r << Requirements::Level.new(:value => level, :visible => false)
    end
  end

  def as_json(*args)
    {
      :name => name,
      :description => description,
      :pictures => pictures.urls
    }
  end
end