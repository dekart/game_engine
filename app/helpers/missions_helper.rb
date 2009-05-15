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
            image_tag(requirement.item.image.url(:icon)),
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
end
