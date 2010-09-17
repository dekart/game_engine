module MissionGroupsHelper
  class GroupTabBuilder
    attr_reader :template

    delegate :capture, :concat, :current_character, :to => :template

    def initialize(template)
      @template = template
    end

    def previous_tab(&block)
      @previous_group = block
    end

    def next_tab(&block)
      @next_group = block
    end

    def group_tab(&block)
      @group = block
    end

    def html
      yield(self)

      groups        = MissionGroup.with_state(:visible).all(:order => :level)
      current_group = current_character.mission_groups.current
      limit         = Setting.i(:mission_group_show_limit)

      position = groups.index(current_group)

      if position < limit - 1
        page = :first
        
        visible_groups = groups[0, limit - 1]
      elsif position > groups.size - limit
        page = :last

        visible_groups = groups[- (limit - 1), limit - 1]
      else
        visible_groups = groups[((position - 1) / (limit - 2)) * (limit - 2) + 1, limit - 2]
      end

      if @previous_group and page != :first and group = groups[groups.index(visible_groups.first) - 1]
        previous_group = capture(group, groups.first.level, &@previous_group)
      else
        previous_group = ""
      end

      if @next_group and page != :last and group = groups[groups.index(visible_groups.last) + 1]
        next_group = capture(group, group.level, &@next_group)
      else
        next_group = ""
      end

      result = ""

      visible_groups.each do |group|
        locked = group.locked?(current_character)
        current = (group == current_group)

        if group == visible_groups.first && previous_group.blank?
          position = :first
        elsif group == visible_groups.last && next_group.blank?
          position = :last
        else
          position = nil
        end

        result << capture(group, locked, current, position, &@group)
      end

      result = [previous_group, result, next_group].join(" ").html_safe

      block_given? ? concat(result) : result
    end
  end

  def mission_group_tabs(&block)
    GroupTabBuilder.new(self).html(&block)
  end
end