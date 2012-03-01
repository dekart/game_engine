module ClansHelper
  def clan_button
    if current_character.clan
      link_to(button(:my_clan), clan_path(current_character.clan), :class => "button" )
    else
      link_to(
        button(:create,
          :price => span_tag(Setting.i(:clan_create_for_vip_money), :vip_money)
        ),
        new_clan_path,
        :class => "button"
      )
    end
  end

  def clan_avatar(clan, options = {})
    image_tag(
      clan.image? ? clan.image.url(options[:format]) : image_path((options[:format] == :small) ? :clan_avatar_small : :clan_avatar), 
      options.merge(:alt => clan.name)
    )
  end
end
