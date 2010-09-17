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

    def html(groups, current_group = nil)
      yield(self)

      if @previous_group and groups.previous_page and group = groups.first.previous_group
        previous_group = capture(group, groups.first.level, &@previous_group)
      else
        previous_group = ""
      end

      if @next_group and groups.next_page and group = groups.last.next_group
        next_group = capture(group, group.level, &@next_group)
      else
        next_group = ""
      end

      result = ""

      groups.each do |group|
        locked = group.locked?(current_character)
        current = (group == current_group)

        if group == groups.first && previous_group.blank?
          position = :first
        elsif group == groups.last && next_group.blank?
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

  def mission_group_tabs(groups, current_group, &block)
    GroupTabBuilder.new(self).html(groups, current_group, &block)
  end
end