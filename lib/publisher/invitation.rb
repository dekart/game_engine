module Publisher
  class Invitation < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def notification(invitation)
      Facebooker::Session.create.post("facebook.dashboard.addNews",
        :uid => invitation.sender.facebook_id,
        :news => [
          {
            :message => I18n.t("news.invitation.text",
              :user => "@:#{invitation.receiver_id}"
            ),
            :action_link => {
              :text => I18n.t("news.invitation.link"),
              :href => relations_url
            }
          }
        ]
      )
    end
  end
end
