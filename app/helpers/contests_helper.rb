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
  
  def contest_image(contest, format, options = {})
    if contest.image?
      content_tag(:div, 
        image_tag(contest.image.url(format), options),
        :class => 'image'
      )
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
end