module CharactersHelper
  def character_name(character, options = {})
    character.name.blank? ? fb_name(character.user, {:linked => false}.merge(options)) : character.name
  end
end
