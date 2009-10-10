class HelpResult < ActiveRecord::Base
  belongs_to :help_request, :counter_cache => true
  belongs_to :character

  delegate :context, :to => :help_request

  validate_on_create :check_expired_request, :check_already_helped
  
  before_create :calculate_payout
  after_create  :give_payout, :increment_request_stats

  attr_reader :fight

  protected

  def check_expired_request
    self.errors.add_to_base(:too_late) if self.help_request.expired?
  end

  def check_already_helped
    Rails.logger.debug self.help_request.inspect
    
    if self.help_request.help_results.find_by_character_id(self.character.id)
      self.errors.add_to_base(:"already_helped_with_#{context.class.to_s.underscore}")
    end
  end

  def calculate_payout
    if context.is_a?(Mission)
      self.money      = (self.help_request.context.money * Configuration[:help_request_mission_money] * 0.01).ceil
      self.experience = (self.help_request.context.experience * Configuration[:help_request_mission_experience] * 0.01).ceil
    elsif context.is_a?(Fight)
      @fight = Fight.create(
        :attacker => character,
        :victim   => context.victim,
        :cause    => help_request
      )
      
      self.money      = @fight.attacker_won? ? (@fight.money * Configuration[:help_request_fight_money] * 0.01).ceil : 0
      self.experience = @fight.attacker_won? ? (@fight.experience * Configuration[:help_request_fight_experience] * 0.01).ceil : 0
    end
  end

  def give_payout
    if context.is_a?(Mission)
      self.character.basic_money  += self.money
      self.character.experience   += self.experience
      self.character.save
    end

    self.help_request.character.basic_money += self.money
    self.help_request.character.experience  += self.experience

    self.help_request.character.save if self.help_request.character.changed?
  end

  def increment_request_stats
    self.help_request.increment(:money, self.money)
    self.help_request.increment(:experience, self.experience)
    self.help_request.save!
  end
end
