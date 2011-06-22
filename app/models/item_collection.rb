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

  def item_ids
    self[:item_ids].to_s.split(",")
  end

  def item_ids=(value)
    self[:item_ids] = value.is_a?(Array) ? value.join(",") : value
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
          :visible  => true
        )
      }
    )
  end

  def missing_items(character)
    items - character.items
  end

  def event_data
    data = {
      :reference_id => self.id,
      :reference_type => "Collection"
    }
  end

  protected

  def check_item_list
    errors.add(:items, :not_enough_items) unless items.any?
  end
end
