class MissionHelpResult < ActiveRecord::Base
  belongs_to :character
  belongs_to :requester, :class_name => 'Character'
  belongs_to :mission
  
  before_create :give_payout
  
  protected
  
  def validate_on_create
    errors.add_to_base(:already_helped) if self.class.first(:conditions => {:character_id => character_id, :requester_id => requester_id, :mission_id => mission_id})
    errors.add_to_base(:cannot_help_themself) if character_id == requester_id
  end

  def give_payout
    level = requester.mission_levels.rank_for(mission).level

    self.money      = Setting.p(:help_request_mission_money, level.money).ceil
    self.experience = Setting.p(:help_request_mission_experience, level.experience).ceil

    character.experience += experience

    character.charge!(- money, 0, self)
  end
end
