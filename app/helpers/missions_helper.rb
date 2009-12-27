module MissionsHelper
  def mission_progress(character, mission)
    rank = character.rank_for_mission(mission)

    if rank.completed?
      content_tag(:div, t("missions.helpers.completed"), :class => :text) +
      content_tag(:div, "", :class => "bar completed")
    else
      percentage = (rank.win_count.to_f / rank.mission.win_amount * 100)

      content_tag(:div, "%d%%" % percentage, :class => :text) +
      content_tag(:div,
        content_tag(:div, "", :class => :percentage, :style => "width: #{percentage}%"),
        :class => :bar
      )
    end
  end
  safe_helper :mission_progress

  def mission_requirements(mission, filter = nil)
    returning result = "" do
      mission.requirements.each do |requirement|
        next if filter == :unsatisfied and requirement.satisfies?(current_character)

        result << render(
          :partial => "requirements/#{requirement.name}", 
          :locals => {:requirement => requirement, :satisfied => requirement.satisfies?(current_character)}
        )
      end
    end
  end
  safe_helper :mission_requirements

  def mission_payouts(mission, display_all = true)
    returning result = "" do
      mission.payouts.each do |payout|
        next unless display_all || payout.visible
        
        result << render(
          :partial  => "payouts/#{payout.name}",
          :locals   => {:payout => payout}
        )
      end
    end
  end
  safe_helper :mission_payouts
end
