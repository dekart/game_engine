class Character
  module Assignments
    def self.included(base)
      base.class_eval do
        has_many :assignments,
          :as         => :context,
          :extend     => AssignmentsAssociationExtension,
          :dependent  => :delete_all
      end
    end
    
    module AssignmentsAssociationExtension
      Assignment::ROLES.each do |role|
        class_eval %[
          def #{role}_effect
            by_role('#{role}').try(:effect_value) || 0
          end
        ]
      end

      def by_role(role)
        role = role.to_s

        all(:include => {:relation => :character}).detect{|a| a.role == role }
      end
    end
  end
end