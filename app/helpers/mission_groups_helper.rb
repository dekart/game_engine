module MissionGroupsHelper
  class GroupTabBuilder
    attr_reader :template

    delegate :dom_id, :dom_class, :capture, :concat, :javascript_tag, :current_character, :to => :template

    def initialize(template)
      @template = template
    end

    def group_tab(&block)
      @group = block
    end

    def groups
      @groups ||= MissionGroup.with_state(:visible).select do |group|
        !group.hide_unsatisfied? || group.requirements.satisfies?(current_character)
      end
    end

    def html
      return if groups.empty?

      yield(self)

      current_group = current_character.mission_groups.current

      result = ""

      groups.each do |group|
        locked = !group.requirements.satisfies?(current_character)

        result << %{
          <li
            id="#{ dom_id(group) }"
            class="#{ dom_class(group) } #{ :locked if locked }"
          >
            #{ capture(group, locked, &@group) }
          </li>
        }
      end

      result = (
        %{
          <div id="mission_group_list" class="clearfix">
            <ul>#{ result }</ul>
          </div>
          <script type="text/javascript">
            $(function(){
              $('#mission_group_list').missionGroups('##{ dom_id(current_group) }', #{ Setting.i(:mission_group_show_limit) });
            });
          </script>
        }
      ).html_safe

      block_given? ? concat(result) : result
    end
  end

  def mission_group_tabs(&block)
    GroupTabBuilder.new(self).html(&block)
  end
end
