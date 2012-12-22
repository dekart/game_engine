module AssignmentsHelper
  def assignment_effect(*attr)
    options = attr.extract_options!

    options.reverse_merge!(
      :format => :full
    )

    if attr.size == 1
      assignment = attr.first

      assignment.effect_value
    else
      assignment, relation = *attr

      Assignment.effect_value(assignment.context, relation, assignment.role)
    end
  end
end
