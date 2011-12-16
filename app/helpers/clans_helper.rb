module ClansHelper
  def clan_button
    if current_character.clan
      link_to(button(:my_clan), clan_path(current_character.clan), :class => "button" )
    else
      link_to(button(:create_clan, :price => content_tag(:span, Setting.i(:clan_create_for_vip_money), :class => :vip_money)), new_clan_path, :class => "button" )
    end
  end
  
  def clan_avatar(clan, options = {})
    image_tag(clan.image? ? clan.image.url(options[:format]) : asset_image_path(:clan_avatar), options.merge(:alt => clan.name))
  end
end
