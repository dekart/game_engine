module MissionGroupsHelper
  class GroupTabBuilder
    attr_reader :template

    delegate :dom_id, :dom_class, :capture, :concat, :javascript_tag, :current_character, :to => :template

    def initialize(template, groups, current_group)
      @template = template
      @groups = groups
      @current_group = current_group
    end

    def group_tab(&block)
      @tab = block
    end

    def html
      return if @groups.empty?

      yield(self)

      result = ""

      @groups.each do |group|
        locked = !group.requirements(current_character).satisfied?

        result << %{
          <li
            id="#{ group.to_key }"
            class="mission_group #{ :locked if locked }"
          >
            #{ capture(group, locked, &@tab) }
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
              $('#mission_group_list').missionGroups('##{ @current_group.to_key }', #{ Setting.i(:mission_group_show_limit) });
            });
          </script>
        }
      ).html_safe

      block_given? ? concat(result) : result
    end
  end

  def mission_group_tabs(groups, current_group, &block)
    GroupTabBuilder.new(self, groups, current_group).html(&block)
  end
end
