class Item < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements
  extend HasEffects
  extend HasPictures
  include HasVisibility

  AVAILABILITIES = [:shop, :special, :loot, :mission, :gift]
  PURCHASEABLE = [:shop, :special]

  BOOST_TYPES = {
    :fight => [:attack, :defence], 
    :monster => [:attack]
  }

  belongs_to  :item_group
  has_many    :inventories, :dependent => :destroy
  
  has_many    :app_requests, 
    :as => :target, 
    :class_name => 'AppRequest::Base'

  named_scope :available, Proc.new{
    {
      :conditions => [%{
          (
            items.available_till IS NULL OR
            items.available_till > ?
          )
        },
        Time.now
      ]
    }
  }

  named_scope :available_by_level, Proc.new {|character|
    {
      :conditions => ["items.level <= ?", character.level]
    }
  }

  named_scope :available_in, Proc.new{|*keys|
    valid_keys = keys.collect{|k| k.try(:to_sym) } & AVAILABILITIES # Find intersections between passed key list and available keys

    if valid_keys.any?
      valid_keys.collect!{|k| k.to_s }

      {:conditions => ["items.availability IN (?)", valid_keys]}
    else
      {}
    end
  }
  named_scope :next_for, Proc.new{|character|
    {
      :conditions => ["items.level > ? AND items.availability = 'shop' AND items.state = 'visible'", character.level],
      :order      => "items.level"
    }
  }
  
  named_scope :boosts, Proc.new{|type|
    {
      :conditions => (
        type ? { :boost_type => type } : ["boost_type != ''"]
      )
    } 
  }


  before_save :update_max_vip_price_in_market, :if => :vip_price_changed?

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

  has_pictures :styles => [
    [:large,  "200x200#"],
    [:medium, "120x120#"],
    [:stream, "90x90#"],
    [:small,  "72x72#"],
    [:icon,   "50x50>"]
  ]

  has_payouts :use,
    :visible => true
    
  has_effects

  validates_presence_of :name, :item_group, :availability, :level
  validates_numericality_of :level, :basic_price, :vip_price, :max_vip_price_in_market, :allow_blank => true
  validates_numericality_of :package_size, 
    :greater_than => 0,
    :allow_blank  => true

  class << self
    def select_option(item)
      ["%s (%s)" % [item.name, item.availability], item.id]
    end

    def to_grouped_dropdown
      {}.tap do |result|
        ItemGroup.without_state(:deleted).all(:order => :position).each do |group|
          result[group.name] = without_state(:deleted).all(:conditions =>{:item_group_id => group.id}).collect{|i|
            ["%s (%s)" % [i.name, i.availability], i.id]
          }.sort
        end
      end
    end

    def available_for(character)
      with_state(:visible).available.visible_for(character).available_by_level(character)
    end
    
    def in_shop_for(character)
      available_in(:shop).available_for(character).scoped(
        :order => 'items.level DESC, vip_price DESC'
      )
    end
    
    def discountable_for(character)
      available_in(:shop).available_for(character).scoped(
        :conditions => ["vip_price >= ?", Setting.i(:personal_discount_minimum_price)]
      )
    end

    def special_for(character)
      available_in(:special).available_for(character)
    end
    
    def purchaseable_for(character)
      available_in(*PURCHASEABLE).available_for(character)
    end
    
    def gifts_for(character)
      available_in(:gift).available_for(character).scoped(:order => "items.level DESC")
    end
    
    def boost_types_to_dropdown
      BOOST_TYPES.keys.map {|b| b.to_s}
    end

    def with_effect_ids(name)
      Rails.cache.fetch("items_with_#{ name }_effect", :expires_in => 15.minutes) do
        Item.all(:select => "items.id, items.effects").select { |i| i.effect(name) != 0 }.collect { |i| i.id }
      end
    end

    def with_effect(name)
      scoped(
        :conditions => ["items.id IN (?)", [0] + with_effect_ids(name)]
      )
    end
  end

  (%w{basic_price vip_price}).each do |attribute|
    class_eval %{
      def #{attribute}
        self[:#{attribute}] || 0
      end
    }
  end

  def price?
    basic_price > 0 or vip_price > 0
  end

  def availability
    self[:availability].to_sym
  end

  def time_left
    (available_till - Time.now).to_i
  end

  def plural_name
    self[:plural_name].blank? ? name.pluralize : self[:plural_name]
  end

  def placements
    boost? ? [] : self[:placements].to_s.split(",").collect{|p| p.to_sym }
  end

  def placements=(value)
    value = value.to_s.split(",") unless value.is_a?(Array)

    self[:placements] = value.join(",")
    self[:equippable] = self[:placements].present?
  end

  def placement_options_for_select
    placements.collect{|p|
      [Character::Equipment.placement_name(p), p]
    }
  end

  def package_size
    self[:package_size] || 1
  end

  def can_be_sold?
    self[:can_be_sold] && package_size == 1
  end
  
  def update_max_vip_price_in_market
    self.max_vip_price_in_market ||= vip_price
  end

  def requirements(amount = 1)
    @requirements ||= Requirements::Collection.new(
      Requirements::BasicMoney.new(:value => basic_price * amount),
      Requirements::VipMoney.new(:value => vip_price * amount),
      Requirements::Level.new(:value => level)
    )
  end
  
  def boost?
    !boost_type.blank?
  end
  
  def usable?
    !payouts.empty?
  end
  
  def available_for?(character)
    !self.class.available_for(character).scoped(:conditions => {:id => id}).empty?
  end
  
  def boost_for?(type, destination)
    send("boost_for_#{type}_#{destination}?")
  end
  
  def boost_for_fight_attack?
    effect(:attack) > 0
  end
  
  def boost_for_fight_defence?
    effect(:defence) > 0
  end
  
  def boost_for_monster_attack?
    effect(:damage) > 0
  end

  def increment_owned(value)
    $redis.hincrby("items_owned", id, value)
  end

  def owned
    $redis.hget("items_owned", id).to_i
  end
end
