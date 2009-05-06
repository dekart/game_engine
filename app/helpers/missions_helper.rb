module MissionsHelper
  def mission_progress(rank)
    rank.completed? ? t("missions.helpers.completed") : "%d%%" % (rank.win_count.to_f / rank.mission.win_amount * 100)
  end
end
