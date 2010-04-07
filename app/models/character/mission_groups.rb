class Character
  module MissionGroups
    def current(new_group_id = nil)
      if new_group_id and new_group_id.to_i != proxy_owner.current_mission_group_id
        proxy_owner.update_attribute(:current_mission_group_id, new_group_id)
      end

      group = MissionGroup.find_by_id(proxy_owner.current_mission_group_id) if proxy_owner.current_mission_group_id
      group ||= MissionGroup.with_state(:visible).first
    end

    def current_page
      MissionGroup.with_state(:visible).paginate(
        :page     => (MissionGroup.with_state(:visible).before(current).size.to_f / Setting.i(:mission_group_show_limit)).floor + 1,
        :per_page => Setting.i(:mission_group_show_limit)
      )
    end

    def check_completion!(group)
      rank = rank_for(group)

      if rank.completed?
        rank.save!

        [rank, rank.payouts]
      else
        rank
      end
    end

    def rank_for(group)
      # Rank instance is created from class except of association to avoid rank creation when saving character
      proxy_owner.mission_group_ranks.find_by_mission_group_id(group.id) ||
        MissionGroupRank.new(
          :character      => proxy_owner,
          :mission_group  => group
        )
    end
  end
end