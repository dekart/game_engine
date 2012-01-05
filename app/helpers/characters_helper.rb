module CharactersHelper
  def character_nickname(character)
    if current_user.friends_with?(character)
      t('characters.real_name_with_nickname',
        :first_name => character.user.first_name, 
        :last_name  => character.user.last_name, 
        :nickname   => character.name
      )
    else
      character.name
    end
  end
  
  def character_name(character_or_user, options = {})
    character = character_for(character_or_user)

    if character.name.blank?
      fb_name(character.user, {:linked => false, :useyou => false}.merge(options))
    else
      character_nickname(character)
    end
  end

  def character_picture(character_or_user, options = {})
    character = character_for(character_or_user)

    options[:size] ||= :square
    
    fb_profile_pic(character.user.facebook_id, :size => options[:size], :alt => character.name)
  end

  def character_name_link(character_or_user, link_options = {}, name_options = {})
    character = character_for(character_or_user)

    link_to(character_name(character, name_options), character_url(character.key), link_options)
  end

  def character_picture_link(character_or_user, link_options = {}, picture_options = {})
    character = character_for(character_or_user)

    link_to(character_picture(character, picture_options), character_url(character.key), link_options)
  end

  def character_wall(character, options = {})
    options = options.reverse_merge(
      :url    => character_url(character,
        :canvas => true,
        :reference_code => reference_code(:comment)
      ),
      :width  => 700
    )

    fb_comments(dom_id(character, :wall), options.merge(:numposts => Setting.i(:wall_posts_show_limit)))
  end

  def character_health_bar(character)
    percentage = character.hp.to_f / character.health_points * 100

    percentage_bar(percentage,
      "%s: %d/%d" % [
        Character.human_attribute_name("health"),
        character.hp,
        character.health_points
      ]
    )
  end
  
  def character_level_group(character, group_size = 5)
    delta = character.level % group_size
    
    "%03d-%03d" % [character.level - delta + 1, character.level + group_size - delta]
  end

  protected

  def character_for(character_or_user)
    character_or_user.is_a?(Character) ? character_or_user : character_or_user.character
  end
end
