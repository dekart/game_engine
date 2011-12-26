class Character
  module Ratings
    TOTAL_SCORE_FIELDS = Rating::FIELDS - ['total_score']
    
    def self.included(base)
      base.class_eval do
        after_update :update_rating_values, :if => :rating_fields_changed?
        
        after_create :update_rating_values
      end
    end
    
    def total_score
      TOTAL_SCORE_FIELDS.sum do |field|
        send(field) * Setting.f("total_score_#{ field }_factor")
      end.ceil
    end
    
    def update_rating_values
      Rating.schedule_update(self)

      true
    end
    
    def rating_values
      Rating::FIELDS.map{|field| 
        send(field) 
      }
    end
    
    def publish_total_score_in_facebook
      if Setting.b(:total_score_publishing_in_facebook_enabled) && user.permissions.include?(:publish_actions)
        begin
          Facepalm::Config.default.api_client.put_connections(facebook_id, :scores,
            :score => total_score
          )
        rescue Koala::Facebook::APIError => e
          logger.fatal e.inspect
        end
      end
    end
    
    protected
    
    def rating_fields_changed?
      !(changes.keys & Rating::FIELDS).empty?
    end
  end
end