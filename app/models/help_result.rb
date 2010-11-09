class HelpResult < ActiveRecord::Base
  belongs_to :help_request, :counter_cache => true
  belongs_to :character

  delegate :context, :to => :help_request

  before_create :calculate_payout
  after_create  :give_payout, :increment_request_stats

  attr_reader :fight

  protected

  def validate_on_create
    if help_request.character == character
      errors.add_to_base(:cannot_help_yourself)
    end

    if help_request.expired?
      errors.add_to_base(:too_late)
    end

    if help_request.help_results.find_by_character_id(character.id)
      errors.add_to_base(:"already_helped_with_#{context.class.to_s.underscore}")
    end

    if context.is_a?(Fight) and context.victim == character
      errors.add_to_base(:cannot_attack_self)
    end
  end

  def calculate_payout
    if context.is_a?(Mission)
      level = help_request.character.mission_levels.rank_for(context).level

      self.money      = Setting.p(:help_request_mission_money, level.money).ceil
      self.experience = Setting.p(:help_request_mission_experience, level.experience).ceil
    elsif context.is_a?(Fight)
      @fight = Fight.create(
        :attacker => character,
        :victim   => context.victim,
        :cause    => help_request
      )

      self.money      = @fight.attacker_won? ? Setting.p(:help_request_fight_money, @fight.money).ceil : 0
      self.experience = @fight.attacker_won? ? Setting.p(:help_request_fight_experience, @fight.experience).ceil : 0
    end
  end

  def give_payout
    if context.is_a?(Mission)
      character.experience   += experience

      character.charge!(- money, 0, self)
    end

    help_request.character.experience  += experience

    help_request.character.charge!(- money, 0, help_request)
  end

  def increment_request_stats
    help_request.increment(:money, money)
    help_request.increment(:experience, experience)

    help_request.save!
  end
end
