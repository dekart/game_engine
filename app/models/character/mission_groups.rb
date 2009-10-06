class Character
  module MissionGroups
    def current(new_group_id = nil)
      if new_group_id and new_group_id.to_i != proxy_owner.current_mission_group_id
        proxy_owner.update_attribute(:current_mission_group_id, new_group_id)
      end

      group = MissionGroup.find(proxy_owner.current_mission_group_id) if proxy_owner.current_mission_group_id
      group ||= MissionGroup.first
    end

    def current_page
      paginate(
        :page     => before(current).size / Configuration[:mission_group_show_limit] + 1,
        :per_page => Configuration[:mission_group_show_limit]
      )
    end

    def completed?(group)
      if rank = proxy_owner.mission_group_ranks.find_by_mission_group_id(group.id)
        rank.completed?
      else
        group.missions.count(
          :conditions => ["missions.id NOT IN (?)", proxy_owner.ranks.completed_mission_ids]
        ) == 0
      end
    end
  end
end