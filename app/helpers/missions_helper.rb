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

  def mission_payouts(mission)
    returning result = "" do
      mission.payouts.each do |payout|
        next unless payout.visible
        
        result << render(
          :partial  => "missions/payouts/#{payout.name}",
          :locals   => {:payout => payout}
        )
      end
    end
  end

  safe_helper :mission_progress, :mission_requirements, :mission_payouts
end
