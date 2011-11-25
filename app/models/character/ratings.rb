class Character
  module Ratings
    TOTAL_SCORE_FIELDS = Rating::FIELDS - ['total_score']
    
    def self.included(base)
      base.extend(ClassMethods)
      
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
      Rating.update(self)
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
      
    
    module ClassMethods
      class RatingSorter
        delegate :each_with_index, :to => :characters

        def initialize(attribute, character = nil)
          @attribute, @character = attribute, character
        end
        
        def characters
          @characters ||= begin
            if ids = Rails.cache.read(cache_key)
              Character.find(ids).sort_by{|c| ids.index(c.id) }
            else
              scope.scoped(:limit => Setting.i(:rating_show_limit)).tap do |characters|
                Rails.cache.write(cache_key, characters.map(&:id), :expires_in => 15.minutes)
              end
            end
          end
        end
        
        def position(character)
          (
            characters.index{|c| c.send(@attribute) == character.send(@attribute) } || 
            scope.count(:conditions => ["#{ @attribute } > ?", character.send(@attribute)])
          ) + 1
        end
        
        protected
        
        def scope
          @scope ||= (
            @character ? @character.self_and_relations.scoped(:joins => :user) : Character.scoped(:joins => :user)
          ).scoped(
            :conditions => ['characters.id NOT IN (?)', Character.banned_ids],
            :order      => "characters.%s DESC" % @attribute
          )
        end

        def cache_key
          "rating_by_%s_%s" % [@attribute, :global]
        end
      end
      
      def rated_by(*attr)
        RatingSorter.new(*attr)
      end
    end
  end
end