class Assignment < ActiveRecord::Base
  belongs_to :context, :polymorphic => true
  belongs_to :relation

  validates_presence_of :context_id, :context_type, :relation_id

  before_create :destroy_current_assignments

  def self.effect_value(context, character, role)
    case role.to_sym
    when :guardian
      character.defence
    when :fighter
      character.attack
    end
  end
  
  def effect_value
    self.class.effect_value(self.context, self.relation.target_character, self.role)
  end

  protected

  def destroy_current_assignments
    self.class.find_all_by_relation_id(self.relation_id).each do |assignment|
      assignment.destroy
    end
  end
end
