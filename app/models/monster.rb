class Monster < ActiveRecord::Base
  belongs_to  :monster_type
  belongs_to  :character
  has_many    :monster_fights

  named_scope :visible, Proc.new{
    {
      :conditions => ["(defeated_at IS NULL AND expire_at >= :time) OR (defeated_at >= :time)",
        {:time => Setting.i(:monster_display_time).days.ago}
      ]
    }
  }

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

  delegate :name, :image, :health, :level, :experience, :money, :requirements, :cooling_time, :to => :monster_type

  attr_reader :payouts

  validates_presence_of :character, :monster_type

  before_create :assign_initial_attributes, :apply_fight_start_payouts
  after_create  :create_fight

  def cooling_time_passed?
    created_at <= cooling_time.hours.ago
  end

  protected

  def assign_initial_attributes
    self.hp = health

    self.expire_at = monster_type.fight_time.hours.from_now
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

  def create_fight
    monster_fights.create!(:character => character)
  end
end
