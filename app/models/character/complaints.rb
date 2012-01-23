class Character
  module Complaints
    def self.included(base)
      base.class_eval do
        has_many :complaints, :foreign_key  => "owner_id"
      end
    end
  end
end