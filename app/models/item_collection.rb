class ItemCollection < ActiveRecord::Base
  extend HasPayouts

  has_payouts :collected, :repeat_collected,
    :apply_on => [:collected, :repeat_collected],
    :visible  => true

  validates_presence_of :name, :level
  validates_numericality_of :level, :greater_than => 0, :only_integer => true

  validate :check_item_list, :on => :create

  default_scope :order => "level DESC"

  scope :available_by_level, Proc.new {|character|
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

  def self.used_item_ids
    $memory_store.fetch('items_for_collections', :expires_in => 15.minutes) do
      {}.tap do |result|
        ItemCollection.with_state(:visible).each do |c|
           c.item_ids.each do |item_id|
             result[item_id] ||= {}

             result[item_id][c.id] = c.amount_items[c.item_ids.index(item_id)] || 1
           end
        end
      end
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
    @items ||= Item.find_all_by_id(item_ids)
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
    items.dup.tap do |result|
      character.inventories.each do |inventory| # We need t refactor this to avoid iterating through the whole inventory
        if items.include?(inventory.item) && inventory.amount >= amount_of_item(inventory.item)
          result.delete(inventory.item)
        end
      end
    end
  end

  def enough_of?(inventory)
    inventory.amount >= amount_of_item(inventory.item)
  end

  protected

  def check_item_list
    errors.add(:items, :not_enough_items) unless items.any?
  end
end
