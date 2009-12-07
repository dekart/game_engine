class Character
  module Assignments
    def by_role(role)
      find(:all).find{|a| a.role == role.to_s }
    end

    def effect_value(role)
      (assignment = self.by_role(role)) ? assignment.effect_value : 0
    end
  end
end