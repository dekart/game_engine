class Monster < ActiveRecord::Base
  belongs_to  :monster_type
  belongs_to  :character
  
  belongs_to :killer, :class_name => "Character"
  
  has_many    :monster_fights,
    :dependent => :delete_all
  
  has_many    :app_requests, 
    :as => :target, 
    :class_name => 'AppRequest::Base',
    :dependent => :delete_all

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
    
    before_transition :on => :win do |monster|
      monster.defeated_at = Time.now
    end
    
    after_transition :on => [:win, :expire] do |monster|
      monster.app_requests.for_expire.each do |app_request|
        app_request.expire!
      end
    end
  end

  delegate :name, :pictures, :pictures?, :health, :level, :experience, :money, :requirements, :attack, :defence, :description,
    :minimum_damage, :maximum_damage, :minimum_response, :maximum_response, :average_response, :to => :monster_type

  attr_reader :payouts

  validates_presence_of :character, :monster_type

  before_create :assign_initial_attributes, :apply_fight_start_payouts
  after_create  :create_fight

  before_update :check_negative_health_points
  after_update  :check_winning_status

  def time_remaining
    (expire_at - Time.now).to_i
  end

  def event_data
    {
      :reference_id => self.id,
      :reference_type => "Monster"
    }
  end

  validate :validate_monster, :on => :create

  protected

  def assign_initial_attributes
    self.hp = health

    self.expire_at = monster_type.fight_time.hours.from_now
  end

  def apply_fight_start_payouts
    @payouts = monster_type.payouts.apply(character, :fight_start, monster_type)
  end

  def validate_monster
    return unless character && monster_type

    errors.add_to_base(:recently_attacked) if character.monster_fights.own.current.by_type(monster_type).count > 0

    errors.add(:character, :low_level) if character.level < level

    errors.add(:character, :requirements_not_satisfied) unless requirements.satisfies?(character)
  end

  def create_fight
    monster_fights.create!(:character => character)
  end

  def check_negative_health_points
    self.hp = 0 if hp < 0
  end

  def check_winning_status
    win! if progress? and hp == 0
  end
end
