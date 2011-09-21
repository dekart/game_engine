class Achievement < ActiveRecord::Base
  belongs_to :character
  belongs_to :achievement_type
  
  after_create :clear_achievement_cache, :schedule_notification, :schedule_registration
  
  delegate :name, :description, :image, :image?, :to => :achievement_type
  
  def collect!
    if collected?
      errors.add_to_base(:already_collected)
      
      false
    else
      transaction do
        achievement_type.payouts.apply(character, :achieve, achievement_type).tap do
          character.save!
          
          update_attributes(
            :collected    => true, 
            :collected_at => Time.now
          )
        end
      end
    end
  end
  
  def register_in_facebook!
    if character.user.permissions.include?(:publish_actions)
      client = Koala::Facebook::API.new(
        Koala::Facebook::OAuth.new(Facebooker2.app_id, Facebooker2.secret).get_app_access_token
      )
    
      begin
        client.put_connections(character.facebook_id, :achievements, :achievement => achievement_type.url)
      rescue Koala::Facebook::APIError => e
        logger.fatal e.inspect
      end
    end
  end
  
  protected
  
  def clear_achievement_cache
    Rails.cache.delete(character.achievements.cache_key)

    true
  end
  
  def schedule_notification
    character.notifications.schedule(:new_achievement, :achievement_id => id)
  end
  
  def schedule_registration
    Delayed::Job.enqueue Jobs::AchievementRegistration.new(id)
  end
end
