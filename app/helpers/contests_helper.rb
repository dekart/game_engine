module ContestsHelper
  def current_contest
    @current_contest ||= Contest.current.first
  end
  
  def contest_timer(contest)
    if contest.visible?
      if contest.starting_soon?
        time_left = contest.time_left_to_start
        t_name = "start_time"
      else contest.finished?
        time_left = contest.time_left_to_finish
        t_name = "finish_time"
      end
      
      dom_ready("Timer.start('##{dom_id(contest)}', #{time_left});")
      
      content_tag(:div,
        t(".#{t_name}", 
          :value => content_tag(:span, "", :id => dom_id(contest), :class => :value)
        ).html_safe,
        :class => 'timer')
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
  
  def contest_table(contest, collection, options = {}, &block)
    options.reverse_merge!({
      :include_current => true,
      :current => current_character
    })
    
    result = ""
    
    current_in_leaders = false
    
    collection.each_with_index do |character_result, index|
      character = character_result.character
      
      current_in_leaders = true if character == options[:current]
      
      result << capture(character, character_result.points, index + 1, (character == options[:current]), &block)
    end
    
    if options[:include_current] && !current_in_leaders
      position = contest.position(options[:current])
      character_result = contest.result_for(options[:current])
      points = (character_result ? character_result.points : 0)
      
      result << capture(options[:current], points, position, true, &block)
    end
    
    block_given? ? concat(result.html_safe) : result.html_safe
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