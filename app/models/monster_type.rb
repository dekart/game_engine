class MonsterType < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements
  extend HasEffects
  extend HasPictures
  include HasVisibility

  has_many :monsters

  state_machine :initial => :hidden do
    state :hidden
    state :visible
    state :deleted

    event :publish do
      transition :hidden => :visible
    end

    event :hide do
      transition :visible => :hidden
    end

    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
  end
    
  has_pictures :styles => [
    [:large,  "350x350>"],
    [:normal, "200x200>"],
    [:small,  "120x120>"],
    [:stream, "90x90#"],
    [:icon,   "40x40#"]
  ]

  has_requirements

  has_payouts :victory, :repeat_victory, :fight_start, :success, :repeat_success, :invite,
    :apply_on => [:victory, :repeat_victory]

  has_effects

  validates_presence_of :name, :level, :health, :experience, :money, :fight_time,
    :minimum_damage, :maximum_damage, :minimum_response, :maximum_response
  validates_numericality_of :level, :experience, :money, :fight_time,
    :minimum_damage, :maximum_damage, :minimum_response, :maximum_response, :maximum_reward_collectors,
    :allow_nil    => true,
    :greater_than => 0
    
  def number_of_maximum_reward_collectors
    maximum_reward_collectors || Setting.i(:monsters_maximum_reward_collectors)
  end
  
  def average_response
    (minimum_response + maximum_response) / 2
  end
  
  def applicable_payouts
    if global_payout = GlobalPayout.by_alias('monsters')
      payouts + global_payout.payouts
    else
      payouts
    end
  end

  def payouts_as_json(character)
    triggers = character.monster_types.payout_triggers(self)

    payouts_to_apply = applicable_payouts.by_action(:add).reject{|payout|
      !payout.visible || !triggers.empty? && (triggers & payout.apply_on).empty?
    }

    {}.tap do |result|
      payouts_to_apply.each do |p|
        result[p.name] = p.value
      end

      Rails.logger.error "~~~ RESULT: #{result}"
    end
  end

  def as_json(character)
    {
      :id          => id,
      :name        => name,
      :description => description,
      :level       => level,
      :image_url   => pictures.url(:normal),
      :fight_time  => fight_time,
      :health      => health,
      :reward      => payouts_as_json(character)
    }
  end
end
