class Character
  module Clans
    def self.included(base)
      base.class_eval do
        has_one :clan, :through => :clan_member
        has_one :clan_member
      end
    end
  end
end