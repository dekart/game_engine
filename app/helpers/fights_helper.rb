module FightsHelper
  def fight_description(fight)
    text = t("fights.descriptions.#{ fight.attacker == current_character ? "attack" : "defence" }_#{ fight.winner == current_character ? "won" : "lost" }")

    text << fb_it(:attacker, link_to(character_name(fight.attacker), fight.attacker))
    text << fb_it(:victim, link_to(character_name(fight.victim), fight.victim))
    text << fb_it(:money, content_tag(:span, fight.money, :class => :money))
    text << fb_it(:experience_points, fight.experience)
    text << fb_it(:attacker_damage, fight.attacker_hp_loss)
    text << fb_it(:victim_damage, fight.victim_hp_loss)

    return fb_i(text)
  end
end
