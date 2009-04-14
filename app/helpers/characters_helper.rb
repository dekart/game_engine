module CharactersHelper
  def character_name(character_or_user, options = {})
    character = character_for(character_or_user)

    character.name.blank? ? fb_name(character.user, {:linked => false}.merge(options)) : character.name
  end

  def character_picture(character_or_user, options = {})
    character = character_for(character_or_user)

    fb_profile_pic(character.user, {:linked => false}.merge(options))
  end

  def character_name_link(character_or_user, link_options = {}, name_options = {})
    character = character_for(character_or_user)

    link_to(character_name(character, name_options), character_url(character, :canvas => true), link_options)
  end

  def character_picture_link(character_or_user, link_options = {}, picture_options = {})
    character = character_for(character_or_user)

    link_to(character_picture(character, picture_options), character_url(character, :canvas => true), link_options)
  end

  protected

  def character_for(character_or_user)
    character_or_user.is_a?(Character) ? character_or_user : character_or_user.character
  end
end
