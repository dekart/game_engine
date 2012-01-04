module FightsHelper
  def fight_description(fight)
    t("fights.descriptions.#{ fight.attacker == current_character ? "attack" : "defence" }_#{ fight.winner == current_character ? "won" : "lost" }",

      :attacker           => character_name_link(fight.attacker, {}, {:useyou => true, :capitalize => fight.attacker == current_character}),
      :victim             => character_name_link(fight.victim, {}, {:useyou => true, :capitalize => fight.victim == current_character}),

      :money              => '<span class="attribute basic_money">%s</span>' % number_to_currency(
        fight.winner == current_character ? fight.winner_money : fight.loser_money
      ),

      :experience_points  => '<span class="attribute experience">%s</span>' % fight.experience,
      :attacker_damage    => '<span class="attribute health">%s</span>'     % fight.attacker_hp_loss,
      :victim_damage      => '<span class="attribute health">%s</span>'     % fight.victim_hp_loss
    ).html_safe
  end
end
