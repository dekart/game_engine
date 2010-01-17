module Publisher
  class Character < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def welcome_notification(user)
      send_as :notification
      recipients user
      fbml t("notifications.welcome.text",
        :app      => link_to(t("app_name"), root_url),
        :missions => link_to(t("notifications.welcome.missions"), mission_groups_url),
        :fight    => link_to(t("notifications.welcome.fight"), new_fight_url),
        :alliance => link_to(t("notifications.welcome.alliance"), relations_url),
        :hero     => link_to(t("notifications.welcome.hero"), rating_url)
      )
    end

    def t(*args)
      I18n.t(*args)
    end
  end
end