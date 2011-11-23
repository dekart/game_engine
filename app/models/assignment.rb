class Assignment < ActiveRecord::Base
  ROLES = %w{attack defence fight_damage fight_income mission_energy mission_income}

  belongs_to :context, :polymorphic => true
  belongs_to :relation

  validates_presence_of :context_id, :context_type, :relation_id
  validates_uniqueness_of :role, :scope => [:context_id, :context_type]
  
  validate_on_create :validate_relation_ownership

  before_create :destroy_current_assignments

  class << self
    ROLES.each do |role|
      class_eval %[
        def #{role}_effect
          by_role('#{role}').try(:effect_value) || 0
        end
      ]
    end
    
    def by_role(role)
      role = role.to_s
      
      all(:include => {:relation => :character}).detect{|a| a.role == role }
    end

    def effect_value(context, relation, role)
      case role.to_sym
      when :attack
        Setting.p(:assignment_attack_bonus, relation.attack).ceil
      when :defence
        Setting.p(:assignment_defence_bonus, relation.defence).ceil
      when :fight_damage
        log_percent(relation.level,
          Setting.i(:assignment_fight_damage_multiplier),
          Setting.i(:assignment_fight_damage_divider)
        )
      when :fight_income
        log_percent(relation.level,
          Setting.i(:assignment_fight_income_multiplier),
          Setting.i(:assignment_fight_income_divider)
        )
      when :mission_energy
        log_percent(relation.level,
          Setting.i(:assignment_mission_energy_multiplier),
          Setting.i(:assignment_mission_energy_divider)
        )
      when :mission_income
        log_percent(relation.level,
          Setting.i(:assignment_mission_income_multiplier),
          Setting.i(:assignment_mission_income_divider)
        )
      end
    end

    def log_percent(parameter, multiplier, divider)
      chance = multiplier * Math.log(parameter.to_f / divider)

      chance <= 0 ? 1 : chance.ceil
    end
  end
  
  def character
    context.is_a?(Character) ? context : context.character
  end

  def effect_value
    self.class.effect_value(context, relation, role)
  end

  def event_data
    {
      :reference_id     => relation.character.id,
      :reference_type   => "Character",
      :reference_level  => relation.level,
      :string_value     => role
    }
  end

  protected
  
  def validate_relation_ownership
    errors.add(:relation, :incorrect_owner) if relation && relation.owner != character
  end

  def destroy_current_assignments
    self.class.find_all_by_relation_id(relation_id).each do |assignment|
      assignment.destroy
    end

    true
  end
end
