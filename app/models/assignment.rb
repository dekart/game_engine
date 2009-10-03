class Assignment < ActiveRecord::Base
  ROLES = %w{attack defence fight_damage fight_income mission_energy mission_income}

  belongs_to :context, :polymorphic => true
  belongs_to :relation

  validates_presence_of :context_id, :context_type, :relation_id
  validates_uniqueness_of :role, :scope => [:context_id, :context_type]

  before_create :destroy_current_assignments

  def self.effect_value(context, character, role)
    case role.to_sym
    when :attack
      (character.attack * Configuration[:assignment_attack_bonus] * 0.01).ceil
    when :defence
      (character.defence * Configuration[:assignment_defence_bonus] * 0.01).ceil
    when :fight_damage
      log_percent(character.level,
        Configuration[:assignment_fight_damage_multiplier],
        Configuration[:assignment_fight_damage_divider]
      )
    when :fight_income
      log_percent(character.level,
        Configuration[:assignment_fight_income_multiplier],
        Configuration[:assignment_fight_income_divider]
      )
    when :mission_energy
      log_percent(character.level,
        Configuration[:assignment_mission_energy_multiplier],
        Configuration[:assignment_mission_energy_divider]
      )
    when :mission_income
      log_percent(character.level,
        Configuration[:assignment_mission_income_multiplier],
        Configuration[:assignment_mission_income_divider]
      )
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
