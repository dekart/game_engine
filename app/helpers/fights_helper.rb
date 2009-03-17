module FightsHelper
  def fight_description(fight)
    text = if fight.attacker == current_character
      if fight.winner == current_character
        "You attacked {victim} and WON the battle! You received {money}, +{experience_points} points of experience, and {attacker_damage} points of damage. {victim} was damaged for {victim_damage} points"
      else
        "You attacked {victim} and LOST the battle! You lost {money} and took {attacker_damage} points of damage. {victim} received {victim_damage} points of damage."
      end
    else
      if fight.winner == current_character
        "You was attacked by {attacker} and WON the battle!  You received {money}, +{experience_points} points of experience, and {victim_damage} points of damage. {attacker} was damaged for {attacker_damage} points"
      else
        "You was attacked by {attacker} and LOST the battle! You lost {money} and took {victim_damage} points of damage. {attacker} received {attacker_damage} points of damage."
      end
    end

    text << fb_it(:attacker, link_to(character_name(fight.attacker), fight.attacker))
    text << fb_it(:victim, link_to(character_name(fight.victim), fight.victim))
    text << fb_it(:money, content_tag(:span, fight.money, :class => :money))
    text << fb_it(:experience_points, fight.experience)
    text << fb_it(:attacker_damage, fight.attacker_hp_loss)
    text << fb_it(:victim_damage, fight.victim_hp_loss)

    return fb_i(text)
  end
end
