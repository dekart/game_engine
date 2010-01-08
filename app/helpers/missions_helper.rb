module MissionsHelper
  def mission_progress(character, mission)
    rank = character.rank_for_mission(mission)

    if rank.completed?
      content_tag(:div, t("missions.helpers.completed"), :class => :text) +
      content_tag(:div, content_tag(:div, "", :class => "completed"), :class => :progress_bar)
    else
      percentage = (rank.win_count.to_f / rank.mission.win_amount * 100)

      percentage_bar(percentage, "%d%" % percentage)
    end
  end
  safe_helper :mission_progress

  def mission_money(mission)
    "%s - %s" % [number_to_currency(mission.money_min), number_to_currency(mission.money_max)]
  end
end
