class Character
  module Ratings
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def rated_by(attribute, character = nil)
        cache_key = "rating_by_%s_%s" % [attribute, character ? character.id : :global]
        
        if ids = Rails.cache.read(cache_key)
          Character.scoped(:joins => :user).find(*ids).sort_by{|c| ids.index(c.id) }
        else
          Character.scoped(
            :joins      => :user, 
            :conditions => ['characters.id NOT IN (?)', Character.banned_ids],
            :order      => "characters.%s DESC" % attribute,
            :limit      => Setting.i(:rating_show_limit)
          ).tap do |characters|
            Rails.cache.write(cache_key, characters.map(&:id), :expires_in => 15.minutes)
          end
        end
      end
    end
  end
end