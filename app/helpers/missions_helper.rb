module MissionsHelper
  def mission_progress(character, mission)
    rank = character.rank_for_mission(mission)
    
    progress_text = rank.completed? ? t("missions.helpers.completed") : 

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

        case requirement.name
        when "item"
          result << content_tag(:div,
            fb_tag(:img,
              fb_ta(:alt, fb_i(requirement.item.name)) +
              fb_ta(:title, fb_i(requirement.item.name)) +
              fb_ta(:src, image_path(requirement.item.image.url(:icon)))
            ),
            :class => "item" + (requirement.satisfies?(current_character) ? "" : " not_satisfied")
          )
        end
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
end
