class Achievement < ActiveRecord::Base
  belongs_to :character
  belongs_to :achievement_type
  
  after_create :clear_achievement_cache, :schedule_notification
  
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
  
  protected
  
  def clear_achievement_cache
    Rails.cache.delete(character.achievements.cache_key)
  end
  
  def schedule_notification
    character.notifications.schedule(:new_achievement, :achievement_id => id)
  end
end
