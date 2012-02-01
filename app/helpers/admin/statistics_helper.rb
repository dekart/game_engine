module Admin::StatisticsHelper
  def admin_statistics_amount_change(value)
    t("admin.statistics.amount_change",
      :amount => strong_tag(value)
    ).html_safe
  end

  def admin_statistics_references(totals, day)
    table = totals.map{|reference, count| 
      [reference, count, day.assoc(reference).try(:last)] 
    }.sort_by{|v| 
      [v[2] || 0, v[1]]
    }
    table.reverse!
    
    table.each do |values|
      yield(*values)
    end
  end

  def admin_statistics_reference(reference)
    if reference.is_a?(ActiveRecord::Base)
      result = "(%s) %s" % [
        reference.class.model_name.human,
        link_to(reference.name, [:edit, :admin, reference])
      ]
    else
      result = reference.to_s.humanize
    end

    result.html_safe
  end
  
  def admin_requests_average_amount(value, day)
    t("admin.statistics.average_amount",
      :amount => strong_tag(Statistics::Visits.average_amount(value, day))
    ).html_safe
  end
end
