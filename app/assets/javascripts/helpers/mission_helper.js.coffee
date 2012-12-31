window.MissionHelper =
  missionProgress: (mission)->
    result = ''

    if mission.level.position > 0
      result += """
        <div class="level">#{ I18n.t("missions.level", level: mission.level.position + 1) }</div>
      """

    if mission.level.progress >= mission.level.steps
      result += @progressBar(100, "#{ I18n.t('missions.progress') }: 100%")
    else
      percentage = Math.round(100 * mission.level.progress / mission.level.steps)

      result += @progressBar(percentage, "#{ I18n.t('missions.progress') }: #{ percentage }%")

    @safe result
