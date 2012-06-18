class ClanMember < ActiveRecord::Base
  belongs_to :clan, :counter_cache => :members_count
  belongs_to :character
  
  before_create :remove_from_other_clan
  
  after_create  :remove_all_applications_to_join_clan

  validate :validate_of_max_size_clan, :on => :create
  
  def self.all_clan_creators_facebook_ids
    all(
      :select => "facebook_id" , 
      :joins => {:character => :user }, 
      :conditions => "clan_members.role = 'creator'"
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

    def validate_of_max_size_clan
      errors.add(:clan, :max_size_clan) if clan.clan_members.count >= Setting.i(:clan_max_size)
    end
    
    def schedule_notification(status)
      character.notifications.schedule(:clan_state,
        :clan_id => clan_id,
        :status  => status.to_s
      )
    end
    
    def remove_from_other_clan
      character.clan_member.try(:destroy)
    end
    
    def remove_all_applications_to_join_clan
      character.clan_membership_applications.destroy_all
    end
end