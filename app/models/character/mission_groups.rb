class Character
  module MissionGroups
    def current(new_group_id = nil)
      if new_group_id and new_group_id.to_i != proxy_owner.current_mission_group_id
        proxy_owner.update_attribute(:current_mission_group_id, new_group_id)
      end

      group = MissionGroup.find_by_id(proxy_owner.current_mission_group_id) if proxy_owner.current_mission_group_id
      group ||= MissionGroup.first
    end

    def current_page
      MissionGroup.paginate(
        :page     => (MissionGroup.before(current).size.to_f / Configuration[:mission_group_show_limit]).floor + 1,
        :per_page => Configuration[:mission_group_show_limit]
      )
    end

    def check_completion!(group)
      rank = rank_for(group)

      if completed?(group)
        rank ||= proxy_owner.mission_group_ranks.create(
          :mission_group => group
        )

        [rank, rank.payouts]
      else
        rank
      end
    end

    def rank_for(group)
      proxy_owner.mission_group_ranks.find_by_mission_group_id(group.id)
    end

    def completed?(group)
      if rank = rank_for(group)
        rank.completed?
      else
        group.missions.count(
          :conditions => ["missions.id NOT IN (?)", proxy_owner.missions.completed_ids]
        ) == 0
      end
    end
  end
end