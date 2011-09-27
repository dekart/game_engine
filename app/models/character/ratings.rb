class Character
  module Ratings
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
      
      base.class_eval do
        before_update :update_total_score, :if => :need_to_update_total_score?
        
        before_create :update_total_score
      end
    end
    
    module InstanceMethods
      def count_total_score
        total_score_fields.reduce(0) do |sum, score|
          sum + (self.send(score) * Setting.f("total_score_#{score}_factor")).ceil
        end
      end
      
      def update_total_score
        self.total_score = count_total_score
      end
      
      def update_total_score!
        update_total_score
        save!
      end
      
      def publish_total_score_in_facebook
        if Setting.b(:total_score_publishing_enabled) && user.permissions.include?(:publish_actions)
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
      
        def need_to_update_total_score?
          total_score_fields.find do |score|
            try("#{score}_changed?")
          end
        end
        
        def total_score_fields
          %w(fights_won killed_monsters_count total_monsters_damage total_money missions_succeeded level)
        end
        
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
          "rating_by_%s_%s" % [@attribute, @character ? @character.id : :global]
        end
      end
      
      def rated_by(*attr)
        RatingSorter.new(*attr)
      end
    end
  end
end