class Character
  module Contests
    def self.included(base)
      base.class_eval do
        has_many :character_contests, 
          :dependent  => :delete_all
        
        has_many :contests, 
          :through    => :character_contests
      end
    end
  end
end