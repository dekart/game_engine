class HelpResult < ActiveRecord::Base
  belongs_to :help_request, :counter_cache => true
  belongs_to :character

  validate_on_create :check_expired_request, :check_already_helped
  
  before_create :calculate_payout
  after_create  :give_payout, :increment_request_money

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
    self.money      = (self.help_request.mission.money * 0.05).ceil
    self.experience = (self.help_request.mission.experience * 0.1).ceil
  end

  def give_payout
    self.character.basic_money  += self.money
    self.character.experience   += self.experience
    self.character.save

    self.help_request.character.basic_money += self.money
    self.character.save
  end

  def increment_request_money
    self.help_request.increment!(:money, self.money)
  end
end
