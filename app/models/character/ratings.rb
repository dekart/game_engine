class Character
  module Ratings
    def self.included(base)
      base.extend(ClassMethods)
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