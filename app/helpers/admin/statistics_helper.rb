module Admin::StatisticsHelper
  def admin_statistics_amount_change(value)
    raw t("admin.statistics.amount_change",
      :amount => content_tag(:strong, value)
    )
  end

  def admin_statistics_reference(reference)
    if reference.is_a?(ActiveRecord::Base)
      raw "(%s) %s" % [
        reference.class.human_name,
        link_to(reference.name, [:edit, :admin, reference])
      ]
    else
      reference.to_s.humanize
    end
  end
end
