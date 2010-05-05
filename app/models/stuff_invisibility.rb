class StuffInvisibility < ActiveRecord::Base
  belongs_to :character_type
  belongs_to :stuff, :polymorphic => true

  validates_uniqueness_of :character_type_id, :scope => [:stuff_id, :stuff_type]
end

