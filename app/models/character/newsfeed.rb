class Character
  module Newsfeed
    def self.included(base)
      base.class_eval do
        has_many :news, :class_name => "News::Base"
      end
    end
  end  
end
