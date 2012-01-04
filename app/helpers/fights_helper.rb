module FightsHelper
  def fight_description(fight)
    t("fights.descriptions.#{ fight.attacker == current_character ? "attack" : "defence" }_#{ fight.winner == current_character ? "won" : "lost" }",

      :attacker           => character_name_link(fight.attacker, {}, {:useyou => true, :capitalize => fight.attacker == current_character}),
      :victim             => character_name_link(fight.victim, {}, {:useyou => true, :capitalize => fight.victim == current_character}),

      :money              => span_tag(
        number_to_currency(fight.winner == current_character ? fight.winner_money : fight.loser_money),
        'attribute basic_money'
      ),

      :experience_points  => span_tag(fight.experience, 'attribute experience'),
      :attacker_damage    => span_tag(fight.attacker_hp_loss, 'attribute health'),
      :victim_damage      => span_tag(fight.victim_hp_loss, 'attribute health')
    ).html_safe
  end
end
