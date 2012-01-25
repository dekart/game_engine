class UpgradeRecipe < ActiveRecord::Base

  belongs_to :item
  belongs_to :result, :class_name => "Item"

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

    after_transition :on => :publish, :do => :mark_item_upgradable

    after_transition :on => [:hide, :mark_deleted], :do => :mark_item_not_upgradable
  end

  validates_presence_of :item, :result
  validates_numericality_of :price, :greater_than => 0

  before_save :update_items_state, :if => :item_id_changed? 

  def use!(character, amount)
    return false if character.upgrade_tokens < amount * price

    transaction do
      character.inventories.replace!(item, result, amount)

      character.upgrade_tokens -= amount * price

      character.save
    end
  end

  protected

  def mark_item_upgradable
    item.upgradable = true
    item.save
  end

  def mark_item_not_upgradable
    if UpgradeRecipe.with_state(:visible).select{|rec| rec != self && rec.item == item}.empty?
      item.upgradable = false
      item.save
    end
  end

  def update_items_state
    return if state != "visible"

    previous = Item.find(changes["item_id"].first)

    item.upgradable = true
    item.save

    if UpgradeRecipe.with_state(:visible).select{|rec| rec != self && rec.item == previous}.empty?
      previous.upgradable = false
      previous.save
    end
  end
end