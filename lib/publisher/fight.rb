module Publisher
  class Fight < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end
    
    include FacebookHelper

    def notification(user, fight)
      send_as :notification
      recipients fight.victim.user
      from user
      fbml "attacked you in #{link_to(fb_app_name(:linked => false), root_url)} game and #{fight.attacker_won? ? "WON" : "LOST"}!  #{link_to("Fight Back &raquo;", character_url(fight.attacker))}"
    end

    def attack_template
      one_line_story_template "{*actor*} attacked {*victim*} in #{link_to(fb_app_name(:linked => false), root_url)} game and WON the battle!"
      short_story_template(
        "{*actor*} attacked {*victim*} in #{link_to(fb_app_name(:linked => false), root_url)} game and WON the battle!",
        "{*actor*} received +{*money*} money, +{*experience*} experience, and lost {*attacker_hp_loss*} health points.
         {*victim*} received {*victim_hp_loss*} points of damage"
      )
      action_links(
        action_link("Play #{fb_app_name(:linked => false)} &raquo;", root_url)
      )
    end
  end
end