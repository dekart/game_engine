class Assignment < ActiveRecord::Base
  belongs_to :context, :polymorphic => true
  belongs_to :relation

  validates_presence_of :context_id, :context_type, :relation_id
  validates_uniqueness_of :role, :scope => [:context_id, :context_type]

  before_create :destroy_current_assignments

  def self.effect_value(context, character, role)
    case role.to_sym
    when :attack
      (character.attack * 0.2).ceil
    when :defence
      (character.defence * 0.2).ceil
    when :fight_damage
      log_percent(character.level, 3.5, 1)
    when :fight_income
      log_percent(character.level, 2, 1)
    when :mission_energy
      log_percent(character.level, 1, 4)
    when :mission_income
      log_percent(character.level, 4, 2)
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

  def self.log_percent(parameter, multiplier, divider)
    chance = multiplier * Math.log(parameter.to_f / divider)

    chance <= 0 ? 1 : chance.ceil
  end
end
