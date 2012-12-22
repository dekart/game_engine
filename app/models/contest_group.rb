class ContestGroup < ActiveRecord::Base
  extend HasPayouts

  PAYOUT_TRIGGER = {
    1 => :first,
    2 => :second,
    3 => :third,
    4 => :consolation,
    5 => :consolation,
    6 => :consolation,
    7 => :consolation,
    8 => :consolation,
    9 => :consolation,
    10 => :consolation
  }

  belongs_to :contest

  has_many :character_contest_groups,
    :dependent => :delete_all

  has_many :characters,
    :through => :character_contest_groups

  has_payouts PAYOUT_TRIGGER.values.uniq

  validates_uniqueness_of :max_character_level, :scope => :contest_id

  validates_numericality_of :max_character_level,
    :only_integer => true,
    :greater_than => 0,
    :allow_nil => true

  validates_presence_of :contest_id

  def leaders_with_points(options = {})
    options.reverse_merge!(
      :include => :character,
      :order => 'points DESC'
    )

    character_contest_groups.where(["character_id NOT IN (?)", Character.banned_ids]).scoped(options)
  end

  def leaders_with_points_for_rating
    leaders_with_points(:limit => Setting.i(:contests_leaders_show_limit))
  end

  def result_for(character)
    character_contest_groups.first(:conditions => {:character_id => character.id})
  end

  def position(character)
    if score = result_for(character)
      @conditions = ['character_contest_groups.points > ?', score.points]
    end

    leaders_with_points.count(:conditions => @conditions) + 1
  end

  def rewardable?(character)
    !result_for(character).try(:reward_collected?) and PAYOUT_TRIGGER.keys.include?(position(character))
  end

  def rewarded?(character)
    result_for(character).try(:reward_collected?)
  end

  def apply_reward!(character)
    transaction do
      payouts.apply(character, PAYOUT_TRIGGER[position(character)], contest).tap do |result|
        result_for(character).update_attribute(:reward_collected, true)

        character.save!
      end
    end
  end

  def previous_group
    conditions = begin
      if max_character_level
        ['max_character_level < ? AND max_character_level IS NOT NULL', max_character_level]
      else
        'max_character_level IS NOT NULL'
      end
    end

    contest.groups.first(:conditions => conditions, :order => 'max_character_level DESC')
  end

  def start_level
    if previous = previous_group
      previous.max_character_level + 1
    else
      1
    end
  end

  def title
    if max_character_level
      I18n.t("contest_groups.title.level_from_to",
        :from => start_level,
        :to   => max_character_level
      )
    else
      I18n.t("contest_groups.title.level_to", :from => start_level)
    end
  end
end