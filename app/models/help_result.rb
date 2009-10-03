class HelpResult < ActiveRecord::Base
  belongs_to :help_request, :counter_cache => true
  belongs_to :character

  delegate :context, :to => :help_request

  validate_on_create :check_expired_request, :check_already_helped
  
  before_create :calculate_payout
  after_create  :give_payout, :increment_request_money

  attr_reader :fight

  protected

  def check_expired_request
    self.errors.add_to_base(:too_late) if self.help_request.expired?
  end

  def check_already_helped
    if self.help_request.help_results.find_by_character_id(self.character.id)
      self.errors.add_to_base(:already_helped)
    end
  end

  def calculate_payout
    if context.is_a?(Mission)
      self.money      = (self.help_request.context.money * 0.05).ceil
      self.experience = (self.help_request.context.experience * 0.10).ceil
    elsif context.is_a?(Fight)
      @fight = Fight.create(
        :attacker => character,
        :victim   => context.victim,
        :cause    => help_request
      )
      
      self.money      = @fight.attacker_won? ? (@fight.money * 0.10).ceil : 0
      self.experience = @fight.attacker_won? ? (@fight.experience * 0.20).ceil : 0
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

  def increment_request_money
    self.help_request.increment!(:money, self.money)
  end
end
