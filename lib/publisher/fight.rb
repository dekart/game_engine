module Publisher
  class Fight < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def notification(fight)
      Facebooker::Session.create.post("facebook.dashboard.addNews",
        :uid => fight.victim.user.facebook_id,
        :news => [
          {
            :message => I18n.t("news.fight.#{fight.attacker_won? ? :lost : :won}.text",
              :user => "@:#{fight.attacker.user.facebook_id}"
            ),
            :action_link => {
              :text => I18n.t("news.fight.#{fight.attacker_won? ? :lost : :won}.link"),
              :href => root_url
            }
          }
        ]
      )
    end
  end
end
