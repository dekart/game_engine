module Publisher
  class Invitation < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def invite_template
      one_line_story_template I18n.t("stories.invitation.invite.one_line", :app => fb_app_name)
      short_story_template(
        I18n.t("stories.invitation.invite.short.title", :app => fb_app_name),
        I18n.t("stories.invitation.invite.short.text", :app => fb_app_name)
      )
      action_links(
        action_link(I18n.t("stories.invitation.invite.short.link"), "{*invite_url*}")
      )
    end

    def notification(user, invitation)
      send_as :notification
      recipients invitation.sender
      from user
      fbml fb_i(
        I18n.t("stories.invitation.notification.text") +
        fb_it(:app, link_to(fb_app_name(:linked => false), root_url)) +
        fb_it(:link, link_to(fb_i(I18n.t("stories.invitation.notification.link")) + " &raquo;", relations_url))
      )
    end
  end
end