class ClanMember < ActiveRecord::Base
  belongs_to :clan, :counter_cache => :members_count
  belongs_to :character
  
  before_create :removed_from_other_clan
  
  after_create  :removed_all_applications_to_join_clan
  
  def self.all_clan_creators_facebook_ids
    all(
      :select => "facebook_id" , 
      :joins => {:character => :user }, 
      :conditions => "clan_members.role = 'creator' AND clan_members.character_id = characters.id  AND characters.user_id = users.id"
    ).collect{|m| m.facebook_id.to_i}
  end
  
  def role=(value)
    self[:role] = value.to_s
  end
  
  def role
    self[:role].to_sym
  end
  
  def creator?
    role == :creator
  end
  
  def delete_by_creator!
    transaction do
      destroy
      
      schedule_notification(:excluded)
    end
  end
  
  protected
  
  def schedule_notification(status)
    character.notifications.schedule(:clan_state,
      :clan_id => clan_id,
      :status  => status.to_s
    )
  end
  
  def removed_from_other_clan
    character.clan_member.try(:destroy)
  end
  
  def removed_all_applications_to_join_clan
    character.clan_membership_applications.destroy_all
  end
end