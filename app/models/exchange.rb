class Exchange < ActiveRecord::Base
  belongs_to :item
  belongs_to :character
  
  has_many :exchange_offers,
    :dependent  => :delete_all do
      
    def created_by(character)
      proxy_owner.exchange_offers.scoped(:conditions => {:character_id => character})
    end  
  end
  
  validates_presence_of :item_id, :character_id, :amount, :text
  validates_numericality_of :amount, :greater_than => 0
  validates_length_of :text, :maximum => 1024
  
  validate_on_create :validate_amount_less_or_equals_then_in_inventories, 
    :validate_item_exchangeable
  
  state_machine :initial => :created do
    state :transacted
    state :invalid
    
    event :transact do
      transition :created => :transacted
    end
    
    event :invalidate do
      transition :created => :invalid
    end
    
    after_transition :on => :transact, :do => :transact_exchange_offers
  end
  
  def key
    digest = Digest::MD5.hexdigest("%s-%s" % [id, created_at])

    "%s-%s" % [id, digest[0, 10]]
  end
  
  def inventory
    character.inventories.find_by_item_id(item) if item
  end
  
  def payout
    Payouts::Item.new(:value => item, :amount => amount)
  end
  
  def validate_amount_less_or_equals_then_in_inventories
    if amount && (!inventory || amount > inventory.amount)
      errors.add(:amount, :not_enough)
    end
  end
  
  class << self
    def invalidate_created_by_inventory!(inventory)
      exchange = with_state(:created).find_by_item_id(inventory.item)
    
      if exchange && ((exchange.amount > inventory.amount) || inventory.destroyed?)
        exchange.invalidate!
      end
    end
  end
  
  protected
    
    def validate_item_exchangeable
      errors.add(:item, :not_exchangeable) if item && !item.exchangeable
    end
    
    def transact_exchange_offers(transition)
      begin
        transact_exchange_offers!(transition)
      rescue StateMachine::InvalidTransition
        false
      end
    end
    
    def transact_exchange_offers!(transition)
      accepted_exchange_offer = transition.args.first
      
      raise ArgumentError.new("Transition can't be changed without exchange_offer") unless accepted_exchange_offer
      
      if exchange_offers.exists?(accepted_exchange_offer)
        transaction do 
          exchange_offers.each do |exchange_offer|
            accepted_exchange_offer == exchange_offer ? exchange_offer.accept! : exchange_offer.destroy
          end
        end
      end
    end
end
