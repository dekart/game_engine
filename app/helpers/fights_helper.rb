module FightsHelper
  def fight_description(fight)
    t("fights.descriptions.#{ fight.attacker == current_character ? "attack" : "defence" }_#{ fight.winner == current_character ? "won" : "lost" }",
      
      :attacker           => link_to(character_name(fight.attacker), character_path(fight.attacker.key)),
      :victim             => link_to(character_name(fight.victim), character_path(fight.victim.key)),

      :money              => content_tag(:span, number_to_currency(fight.money),  :class => "attribute basic_money"),
      :experience_points  => content_tag(:span, fight.experience,                 :class => "attribute experience"),
      :attacker_damage    => content_tag(:span, fight.attacker_hp_loss,           :class => "attribute health"),
      :victim_damage      => content_tag(:span, fight.victim_hp_loss,             :class => "attribute health")
    ).html_safe
  end
end
