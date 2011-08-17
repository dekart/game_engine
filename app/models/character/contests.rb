class Character
  module Contests
    def self.included(base)
      base.class_eval do
        has_many :character_contest_groups, 
          :dependent  => :delete_all
          
        has_many :contest_groups, 
          :through => :character_contest_groups
      end
    end
  end
end