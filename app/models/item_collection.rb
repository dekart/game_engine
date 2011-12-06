class ItemCollection < ActiveRecord::Base
  extend HasPayouts

  has_payouts :collected, :repeat_collected,
    :apply_on => [:collected, :repeat_collected],
    :visible  => true

  validates_presence_of :name, :level
  validates_numericality_of :level, :greater_than => 0, :only_integer => true

  validate_on_create :check_item_list

  default_scope :order => "level DESC"

  named_scope :available_by_level, Proc.new {|character|
    {
      :conditions => ["item_collections.level <= ?", character.level]
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
  
  def amount_of_item(item)
    amount_items[item_ids.index(item.id)] || 1
  end

  def item_ids
    self[:item_ids].to_s.split(",").collect{|id| id.to_i}
  end

  def item_ids=(value)
    self[:item_ids] = value.is_a?(Array) ? value.join(",") : value
  end
  
  def amount_items
    self[:amount_items].to_s.split(",").collect{|i| i.to_i }
  end
  
  def amount_items=(value)
    self[:amount_items] = Array.wrap(value).collect{|a| a.blank? ? "1" : a }.join(",")
  end

  def items
    Item.find_all_by_id(item_ids)
  end

  def spendings
    Payouts::Collection.new(
      *items.collect{|item|
        Payouts::Item.new(
          :value    => item,
          :apply_on => :collected,
          :action   => :remove,
          :visible  => true,
          :amount => amount_of_item(item)
        )
      }
    )
  end
  
  def missing_items(character)
    result = items
    
    character.inventories.each do |inventory|
      if items.include?(inventory.item) && inventory.amount >= amount_of_item(inventory.item)
        result.delete(inventory.item)
      end
    end
      
    result
  end 

  def event_data
    data = {
      :reference_id => self.id,
      :reference_type => "Collection"
    }
  end
  
  def enough_of?(inventory)
    inventory.amount >= amount_of_item(inventory.item)
  end

  protected

  def check_item_list
    errors.add(:items, :not_enough_items) unless items.any?
  end
end
