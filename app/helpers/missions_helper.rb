module MissionsHelper
  def mission_list(missions)
    missions.each do |mission|
      if mission.visible?(current_character)
        level = current_character.missions.level_for(mission)
        progress = current_character.missions.progress_for(level)

        yield(mission, level, progress) if !mission.tags.include?(:hide_unsatisfied) or level.requirements(current_character).satisfied?
      end
    end
  end

  def mission_progress(level, progress, options = {})
    result = ""

    if level.mission.levels.size > 1
      result << %{<div class="level">#{ t("missions.mission.level", :level => level.position + 1) }</div>}
    end

    if progress >= level.steps
      result << percentage_bar(100,
        "%s: %d%" % [t('missions.mission.progress'), 100]
      )
    else
      percentage = (100.0 * progress.to_f / level.steps).round

      result << percentage_bar(percentage,
        "%s: %d%" % [t('missions.mission.progress'), percentage]
      )
    end

    result.html_safe
  end

  def mission_money(level)
    "%s - %s" % [
      number_to_currency(level.money_min),
      number_to_currency(level.money_max)
    ]
  end

  def mission_button(mission, progress)
    if mission.button_label.blank?
      button(progress == 0 ? :start : :fulfill)
    else
      button(mission.button_label)
    end
  end
end
