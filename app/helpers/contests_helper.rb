module ContestsHelper
  def current_contest
    @current_contest ||= (Contest.current || Contest.finished_recently.first)
  end
  
  def contest_timer(contest)
    if contest.visible?
      if contest.starting_soon?
        time_left = contest.time_left_to_start
        timer_name = "start_time"
      else contest.finished?
        time_left = contest.time_left_to_finish
        timer_name = "finish_time"
      end
      
      dom_ready("Timer.start('##{dom_id(contest)}', #{time_left});")
      
      content_tag(:div,
        t(".#{timer_name}", 
          :value => content_tag(:span, "", :id => dom_id(contest), :class => :value)
        ).html_safe,
        :class => 'timer'
      )
    end
  end
  
  def contest_current_tag(contest, &block)
    result = content_tag(:div, capture(&block),
      :id     => 'current_contest',
      :class  => 'clearfix',
      :style  => contest_logo_background(contest)
    )
    
    concat(result.html_safe)
  end
  
  def contest_logo_background(contest)
    if contest.image?
      "background-image: url('#{contest.image.url}'); background-repeat: no-repeat;"
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
  
  def contest_points_type_button(contest)
    unless contest.finished?
      case contest.points_type
      when 'fights_won'
        link_to(button(:fights), new_fight_path, :class => 'button fight') unless params[:controller] == 'fights' 
      when 'total_monsters_damage'
        link_to(button(:monsters), monsters_path, :class => 'button monsters') unless params[:controller] == 'monsters'
      end
    end
  end
end