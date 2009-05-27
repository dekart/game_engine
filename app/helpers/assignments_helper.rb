module AssignmentsHelper
  def assignment_effect(*attr)
    if attr.size == 1
      assignment = attr.first
      
      role = assignment.role
      value = assignment.effect_value
    else
      assignment, relation = *attr
      
      value = Assignment.effect_value(assignment.context, relation.target_character, assignment.role)
    end

    fb_i(
      t("assignments.roles.#{assignment.role}.effect") +
      fb_it(:value, value)
    )
  end
end
