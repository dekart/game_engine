module AssignmentExtension
  def by_role(role)
    find(:all).find{|a| a.role == role.to_s }
  end
end