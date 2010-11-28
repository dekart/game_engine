class Monster < ActiveRecord::Base
  belongs_to :monster_type
  belongs_to :character

  state_machine :initial => :progress do
    state :progress
    state :won
    state :expired

    event :win do
      transition :progress => :won
    end

    event :expire do
      transition :progress => :expired
    end
  end

  delegate :name, :health, :level, :requirements, :cooling_time, :to => :monster_type

  attr_reader :payouts

  validates_presence_of :character, :monster_type

  before_create :assign_health_points, :apply_fight_start_payouts

  def cooling_time_passed?
    created_at <= cooling_time.hours.ago
  end

  protected

  def assign_health_points
    self.hp = health
  end

  def apply_fight_start_payouts
    @payouts = monster_type.payouts.apply(character, :fight_start, monster_type)
  end

  def validate_on_create
    return unless character && monster_type

    if recent_monster = character.monsters.find_by_monster_type_id(monster_type.id) and !recent_monster.cooling_time_passed?
      errors.add(:base, :recently_attacked)
    end

    errors.add(:character, :low_level) if character.level < level

    errors.add(:character, :requirements_not_satisfied) unless requirements.satisfies?(character)
  end
end
