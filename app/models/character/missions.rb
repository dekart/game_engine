class Character
  module Missions
    def self.included(base)
      base.class_eval do
        has_many :mission_level_ranks,  :dependent => :delete_all, :extend => MissionLevelRanksExtension
        has_many :mission_ranks,        :dependent => :delete_all
        has_many :mission_group_ranks,  :dependent => :delete_all

        has_many :mission_levels,
          :through  => :mission_level_ranks,
          :source   => :level,
          :extend   => MissionLevelsExtension

        has_many :missions,
          :through  => :mission_ranks,
          :extend   => MissionAssociationExtension

        has_many :mission_groups,
          :through  => :mission_group_ranks,
          :extend   => MissionGroupAssociationExtension
          
        has_many :mission_help_results
        has_many :mission_helps, 
          :class_name   => "MissionHelpResult",
          :foreign_key  => :requester_id,
          :extend       => MissionHelpAssociationExtension
      end
    end

    module MissionLevelRanksExtension
      def incomplete_for(mission)
        first(
          :conditions => {
            :mission_id => mission.id,
            :completed  => false
          }
        )
      end
    end

    module MissionLevelsExtension
      def ranks_for(*missions)
        missions = missions.flatten
        
        level_ids = missions.map do |mission| 
          (mission.level_ids - completed_ids(mission)).first || mission.level_ids.last
        end
        
        ranks = proxy_owner.mission_level_ranks.find_all_by_level_id(level_ids)
        
        missions.map do |mission|
          ranks.detect{|r| r.mission_id == mission.id } || build_rank_for_mission(mission)
        end
      end
      
      def build_rank_for_mission(mission)
        level = mission.levels.find(
          (mission.level_ids - completed_ids(mission)).first
        )

        proxy_owner.mission_level_ranks.build(:level => level, :mission => mission)
      end

      def completed_ids(mission = nil)
        unless @completed_ids
          @completed_ids = {}
          
          proxy_owner.mission_level_ranks.all(
            :select     => "mission_id, level_id",
            :conditions => { :completed  => true }
          ).each do |rank|
            @completed_ids[rank.mission_id] ||= []
            @completed_ids[rank.mission_id] << rank.level_id
          end
        end
        
        mission ? (@completed_ids[mission.id] || []) : @completed_ids.values.flatten
      end
      
      def clear_completed_ids_cache!
        @completed_ids = nil
      end
    end

    module MissionAssociationExtension
      def by_group(group)
        group.missions.with_state(:visible).visible_for(proxy_owner)
      end
      
      def by_current_group
        by_group(proxy_owner.mission_groups.current)
      end
      
      def fulfill!(mission)
        MissionResult.create(proxy_owner, mission)
      end

      def check_completion!(mission)
        rank_for(mission).tap do |rank|
          if rank.completed?
            rank.save!
          
            clear_completed_ids_cache!
          end
        end
      end

      def completed?(mission)
        completed_ids(mission.mission_group).include?(mission.id)
      end

      def completed_ids(group = nil)
        unless @completed_ids
          @completed_ids = {}
          
          proxy_owner.mission_ranks.all(
            :select     => "mission_group_id, mission_id",
            :conditions => {
              :completed        => true,
            }
          ).each do |rank|
            @completed_ids[rank.mission_group_id] ||= []
            @completed_ids[rank.mission_group_id] << rank.mission_id
          end
        end
        
        group ? (@completed_ids[group.id] || []) : @completed_ids.values.flatten
      end
      
      def clear_completed_ids_cache!
        @completed_ids = nil
      end
      
      def rank_for(mission)
        proxy_owner.mission_ranks.find_or_initialize_by_mission_id(mission.id)
      end
      
      def first_levels_completed?(group)
        missions = group.missions.with_state(:visible).all(:select => "id, level_ids_cache")
        
        (missions.map{|m| m.level_ids.first } & proxy_owner.mission_levels.completed_ids).size == missions.size
      end
    end

    module MissionGroupAssociationExtension
      def current(group_id = nil)
        groups = MissionGroup.with_state(:visible)

        group = groups.find_by_id(group_id) if group_id
        group ||= groups.find_by_id(proxy_owner.current_mission_group_id) if proxy_owner.current_mission_group_id
        group ||= first_accessible_group

        proxy_owner.update_attribute(:current_mission_group_id, group.id) if group.id != proxy_owner.current_mission_group_id

        group
      end
      
      def first_accessible_group
        MissionGroup.with_state(:visible).all.detect{|group| 
          group.requirements.satisfies?(proxy_owner)
        }
      end

      def check_completion!(group)
        rank = rank_for(group)

        rank.save! if rank.completed?

        rank
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
    
    module MissionHelpAssociationExtension
      def uncollected
        scoped(:conditions => {:collected => false}, :order => "mission_help_results.created_at DESC")
      end
      
      def collect_reward!
        basic_money = uncollected.sum(:basic_money)
        experience  = uncollected.sum(:experience)
        
        transaction do
          proxy_owner.charge(- basic_money, 0)
          proxy_owner.experience += experience
          
          proxy_owner.save!
          
          uncollected.update_all(:collected => true)
        end
        
        [basic_money, experience]
      end
    end
  end
end
