module Publisher
  class Fight < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    def notification(user, fight)
      send_as :notification
      recipients fight.victim.user
      from user
      fbml "attacked you in <b><fb:application-name /></b> game and #{fight.attacker_won? ? "WON" : "LOST"}! #{link_to("Fight Back!", fight_url(fight))}"
    end
  end
end