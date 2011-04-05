module Admin::StatisticsHelper
  def admin_statistics_amount_change(value)
    t("admin.statistics.amount_change",
      :amount => content_tag(:strong, value)
    ).html_safe
  end
  
  def admin_statistics_references(totals, day)
    total_references = totals.references
    day_references = day.references
    
    total_references.each do |reference, count|
      yield(reference, count, day_references.assoc(reference).try(:last))
    end
  end

  def admin_statistics_reference(reference)
    if reference.is_a?(ActiveRecord::Base)
      result = "(%s) %s" % [
        reference.class.human_name,
        link_to(reference.name, [:edit, :admin, reference])
      ]
    else
      result = reference.to_s.humanize
    end

    result.html_safe
  end
end
