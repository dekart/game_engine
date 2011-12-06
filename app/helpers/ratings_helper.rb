module RatingsHelper
  def rating_table(field, &block)
    rating = Rating.new(field)
    
    result = ""

    current_displayed = false
    
    characters = rating.leaders(Setting.i(:rating_show_limit))
    
    characters.each do |rank, character|
      current_displayed ||= (character == current_character)
      
      result << capture(character, characters.index{|r, c| c == character} + 1, rank, (character == current_character), &block)
    end

    unless current_displayed # Adding current character to the end of the table if it wasn't in the leader list
      result << capture(current_character, rating.position(current_character), current_character.send(field), true, &block)
    end

    block_given? ? concat(result.html_safe) : result.html_safe
  end
  
  def rating_publish_button(position, rating_name)
    return unless Setting.b(:stream_dialog_enabled)
    
    link_to_function(button(t("ratings.show.buttons.publish")), stream_dialog(:position_in_rating, position, rating_name),
      :class => 'button publish'
    )
  end
end
