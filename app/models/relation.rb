class Relation < ActiveRecord::Base
  belongs_to  :source_character, :foreign_key => "source_id", :class_name => "Character", :counter_cache => true
  
  #TODO Check size of the 'bag' placement when relation is getting removed
end
