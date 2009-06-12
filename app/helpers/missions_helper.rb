module MissionsHelper
  def mission_progress(character, mission)
    rank = character.rank_for_mission(mission)
    
    rank.completed? ? t("missions.helpers.completed") : "%d%%" % (rank.win_count.to_f / rank.mission.win_amount * 100)
  end

  def mission_requirements(mission)
    returning result = "" do
      mission.requirements.each do |requirement|
        case requirement.name
        when "item"
          result << content_tag(:div,
            fb_tag(:img,
              fb_ta(:alt, fb_i(requirement.item.name)) +
              fb_ta(:title, fb_i(requirement.item.name)) +
              fb_ta(:src, image_path(requirement.item.image.url(:icon)))
            ),
            :class => "item" + (" not_satisfied" unless requirement.satisfies?(current_character))
          )
        end
      end
    end
  end

  def mission_payouts(mission)
    returning result = "" do
      mission.payouts.each do |payout|
        next unless payout.options[:visible]

        result << render(:partial => "missions/payouts/#{payout.name}", :locals => {:payout => payout})
      end
    end
  end

  def mission_payouts_received(mission_result, action)
    returning result = "" do
      mission_result.payouts.by_action(action).each do |payout|
        result << render(
          :partial  => "missions/received_payouts/#{payout.class.to_s.underscore.split("/").last}",
          :locals   => {:payout => payout}
        )
      end
    end
  end
end
