module FightsHelper
  def fight_description(fight)
    text = t("fights.descriptions.#{ fight.attacker == current_character ? "attack" : "defence" }_#{ fight.winner == current_character ? "won" : "lost" }")

    text << fb_it(:attacker, link_to(character_name(fight.attacker), fight.attacker))
    text << fb_it(:victim, link_to(character_name(fight.victim), fight.victim))
    text << fb_it(:money, content_tag(:span, number_to_currency(fight.money), :class => "attr basic_money"))
    text << fb_it(:experience_points, content_tag(:span, fight.experience, :class => "attr experience"))
    text << fb_it(:attacker_damage, content_tag(:span, fight.attacker_hp_loss, :class => "attr health"))
    text << fb_it(:victim_damage, content_tag(:span, fight.victim_hp_loss, :class => "attr health"))

    return fb_i(text)
  end
end
