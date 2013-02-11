class Achievement < ActiveRecord::Base
  belongs_to :character
  belongs_to :achievement_type

  after_create :clear_achievement_cache, :schedule_notification, :schedule_registration

  delegate :name, :description, :pictures, :pictures?, :to => :achievement_type

  def collect!
    if collected?
      errors.add(:base, :already_collected)

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
    begin
      Facepalm::Config.default.api_client.put_connections(character.facebook_id, :achievements, :achievement => achievement_type.url)
    rescue Koala::Facebook::APIError => e
      logger.fatal e.inspect
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
