module Publisher
  class Invitation < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def notification(user, invitation)
      send_as :notification
      recipients invitation.sender
      from user
      fbml I18n.t("notifications.invitation.text",
        :app  => link_to(fb_app_name(:linked => false), root_url),
        :link => link_to(I18n.t("notifications.invitation.link"), relations_url)
      )
    end
  end
end