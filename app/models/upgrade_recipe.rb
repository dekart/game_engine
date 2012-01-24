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

    after_transition :on => :publish do |recipe|
      recipe.item.upgradable = true
      recipe.item.save
    end

    after_transition :on => [:hide, :mark_deleted] do |recipe|
      if UpgradeRecipe.with_state(:visible).select{|rec| rec != @recipe && rec.item == recipe.item}.empty?
        recipe.item.upgradable = false
        recipe.item.save
      end
    end
  end

  validates_presence_of :item, :result
  validates_numericality_of :price, :greater_than => 0

  def use!(character, amount)
    return false if character.upgrade_tokens < amount * price

    transaction do
      character.inventories.replace!(item, result, amount)

      character.upgrade_tokens -= amount * price

      character.save
    end
  end

end