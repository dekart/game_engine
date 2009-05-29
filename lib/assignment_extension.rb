module AssignmentExtension
  def by_role(role)
    find(:all).find{|a| a.role == role.to_s }
  end

  def effect_value(role)
    return 0 unless assignment = self.by_role(role)
    return assignment.effect_value
  end
end