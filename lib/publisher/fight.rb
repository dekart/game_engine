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
      fbml "attacked you in <b><fb:application-name /></b> game and #{fight.attacker_won? ? "WON" : "LOST"}! #{link_to("Fight Back!", fight_url(fight))}"
    end

    def wall_template
      one_line_story_template "{*actor*} attacked {*target*} in #{link_to(fb_app_name, root_url(:canvas => true))} game and WON the battle"
      short_story_template(
        "{*actor*} attacked {*target*} in #{link_to(fb_app_name, root_url(:canvas => true))} game and WON the battle",
        "{*actor*} received +{*money*} money, +{*experience*} experience, and lost {*attacker_hp_loss*} health points.
         {*target*} received {*victim_hp_loss*} points of damage"
      )
    end
  end
end