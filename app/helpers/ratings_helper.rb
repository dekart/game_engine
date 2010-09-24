module RatingsHelper
  def rating_table(characters, field, include_self = true, &block)
    result = ""

    characters.each_with_index do |character, index|
      current = (character == current_character)

      result << capture(character, index + 1, current, &block)
    end

    if include_self && !characters.include?(current_character)
      position = characters.rating_position(current_character, field)

      result << capture(current_character, position, current, &block)
    end

    block_given? ? concat(result.html_safe) : result.html_safe
  end
end
