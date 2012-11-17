module ContestsHelper
  def current_contest
    @current_contest ||= (Contest.current || Contest.finished_recently.first)
  end

  def contest_timer(contest)
    if contest.started?
      time_left = contest.time_left_to_finish
      timer_name = "finish_time"
    else
      time_left = contest.time_left_to_start
      timer_name = "start_time"
    end

    dom_ready("new VisualTimer(['##{dom_id(contest)}']).start(#{time_left});")

    (
      %{
        <div class="timer">
          #{ t(".#{ timer_name }") }
          <span class="value" id="#{ dom_id(contest) }"></span>
        </div>
      }
    ).html_safe
  end

  def contest_current_tag(contest, &block)
    result = %{<div class="clearfix" id="current_contest" style="#{ contest_logo_background(contest) }">#{ capture(&block) }</div>}

    concat(result.html_safe)
  end

  def contest_logo_background(contest)
    if contest.pictures?
      "background-image: url('#{ contest.pictures.url }'); background-repeat: no-repeat;"
    end
  end

  def contest_group_table(contest_group, options = {}, &block)
    contest = contest_group.contest

    options.reverse_merge!(
      :include_current => true,
      :current => current_character
    )

    result = ""

    current_in_leaders = false

    contest_group.leaders_with_points_for_rating.each_with_index do |character_result, index|
      character = character_result.character

      current_in_leaders = (character == options[:current])

      result << capture(character, character_result.points, index + 1, (character == options[:current]), &block)
    end

    if options[:include_current] && !current_in_leaders && contest.group_for(options[:current]) == contest_group
      position = contest.position(options[:current])
      character_result = contest.result_for(options[:current])
      points = (character_result ? character_result.points : 0)

      result << capture(options[:current], points, position, true, &block)
    end

    result = result.html_safe

    block_given? ? concat(result) : result
  end

  def contest_action_button(contest)
    if contest.points_type == 'fights_won' and params[:controller] != 'fights'
      link_to(button(:fights), new_fight_path,
        :class => 'button fight'
      )
    elsif contest.points_type == 'total_monsters_damage' and params[:controller] != 'monsters'
      link_to(button(:monsters), monsters_path,
        :class => 'button monsters'
      )
    end
  end
end