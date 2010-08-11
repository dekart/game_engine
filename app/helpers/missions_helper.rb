module MissionsHelper
  def mission_progress(character, mission)
    rank = character.rank_for_mission(mission)

    if rank.completed?
      result = percentage_bar(100, :label => t("missions.mission.completed"))
    else
      percentage = (rank.win_count.to_f / rank.mission.win_amount * 100)

      result = percentage_bar(percentage,
        :label => "%s: %d%" % [Mission.human_attribute_name("progress"), percentage]
      )
    end

    result.html_safe
  end

  def mission_money(mission)
    "%s - %s" % [number_to_currency(mission.money_min), number_to_currency(mission.money_max)]
  end
end
