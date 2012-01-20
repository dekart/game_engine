class ExchangeOffer < ActiveRecord::Base
  belongs_to :exchange
  belongs_to :item
  belongs_to :character
  
  validates_presence_of :exchange_id, :item_id, :character_id, :amount
  validates_numericality_of :amount, :greater_than => 0
  
  validate :validate_amount_less_or_equals_then_in_inventories,
    :validate_item_exchangeable, :on => :create
  
  after_create :send_created_notification_to_exchanger
  
  state_machine :initial => :created do
    state :accepted
    
    event :accept do
      transition :created => :accepted, :if => :validate_characters_has_items_in_inventories
    end
    
    after_transition :on => :accept, :do => [:make_exchange!, :send_accepted_notification]
  end
  
  def inventory
    character.inventories.find_by_item_id(item) if item
  end
  
  def payout
    Payouts::Item.new(:value => item, :amount => amount)
  end
  
  class << self
    def destroy_created_by_inventory(inventory)
      exchange_offers = with_state(:created).all(:conditions => {:item_id => inventory.item})
    
      ExchangeOffer.transaction do
        exchange_offers.each do |exchange_offer|
          if exchange_offer.amount > inventory.amount || inventory.destroyed?
            exchange_offer.destroy
          end
        end
      end
    end
  end
  
  protected
    
    # Split item selection and item amount checks to two different validations
    def validate_amount_less_or_equals_then_in_inventories
      if amount && (!inventory || amount > inventory.amount)
        errors.add(:amount, :not_enough) 
      end
    end
    
    def validate_item_exchangeable
      errors.add(:item, :not_exchangeable) if item && !item.exchangeable
    end
    
    def send_created_notification_to_exchanger
      exchange.character.notifications.schedule(:exchange_offer_created, :exchange_offer_id => id)
    end
    
    def send_accepted_notification
      character.notifications.schedule(:exchange_offer_accepted, :exchange_offer_id => id)
    end
    
    def validate_characters_has_items_in_inventories
      !validate_amount_less_or_equals_then_in_inventories && !exchange.validate_amount_less_or_equals_then_in_inventories
    end
    
    def make_exchange!
      exchanger = exchange.character
    
      transaction do
        character.inventories.transfer!(exchanger, item, amount)
        exchanger.inventories.transfer!(character, exchange.item, exchange.amount)
      end
    end
end