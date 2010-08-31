module RatingsHelper
  def rating_table(characters, field, &block)
    result = ""

    characters.each_with_index do |character, index|
      current = (character == current_character)

      if current and character == characters.last
        position = characters.count(:conditions => ["#{field} > ?", character.send(field)]) + 1
      else
        position = index + 1
      end

      result << capture(character, position, current, &block)
    end

    block_given? ? concat(result.html_safe) : result.html_safe
  end
end
