class Relation < ActiveRecord::Base
  belongs_to  :source_character, :foreign_key => "source_id", :class_name => "Character", :counter_cache => true

  after_create :recalculate_character_inventories
  after_destroy :recalculate_character_inventories
  
  protected

  def recalculate_character_inventories
    self.source_character.inventories.calculate_used_in_fight!
  end
end
