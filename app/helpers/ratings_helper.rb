module RatingsHelper
  def rating_table(characters, field, current = current_character, include_current = true, &block)
    result = ""

    current_displayed = false
    
    characters.each_with_index do |character, index|
      current_displayed ||= (character == current)
      
      result << capture(character, characters.position(character), (character == current), &block)
    end

    if include_current && current && !current_displayed
      result << capture(current, characters.position(character), true, &block)
    end

    block_given? ? concat(result.html_safe) : result.html_safe
  end
end
