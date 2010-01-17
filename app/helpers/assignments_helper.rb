module AssignmentsHelper
  def assignment_effect(*attr)
    options = attr.extract_options!

    if attr.size == 1
      assignment = attr.first
      
      value = assignment.effect_value
    else
      assignment, relation = *attr
      
      value = Assignment.effect_value(assignment.context, relation.target_character, assignment.role)
    end

    t("assignments.roles.#{assignment.role}.effect.#{options[:format] || :full}",
      :value => value
    )
  end
end
