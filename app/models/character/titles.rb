class Character
  module Titles
    def self.included(base)
      base.class_eval do
        has_many :character_titles
        has_many :titles, :through => :character_titles
      end
    end
  end
end