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
      fbml I18n.t("notifications.fight.text",
        :app  => link_to(fb_app_name(:linked => false), root_url),
        :link => link_to(I18n.t('notifications.fight.link'), root_url)
      )
    end

    def invitation(user, victim)
      send_as :notification
      recipients victim
      from user
      fbml I18n.t("notifications.fight_with_invite.text",
        :app  => link_to(fb_app_name(:linked => false), root_url),
        :link => link_to(I18n.t('notifications.fight_with_invite.link'), root_url)
      )
    end
  end
end