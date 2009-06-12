module Publisher
  class Assignment < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def notification(user, assignment)
      send_as :notification
      recipients assignment.relation.target_character.user
      from user
      fbml fb_i(
        I18n.t("stories.assignment.notification.text",
          :pronoun  => fb_pronoun(user, :possessive => true, :useyou => false)
        ) +
        fb_it(:title, content_tag(:b, fb_i(I18n.t("assignments.roles.#{assignment.role}.title")))) +
        fb_it(:app, link_to(fb_app_name(:linked => false), root_url)) +
        fb_it(:link,
          link_to(
            fb_i(
              I18n.t("stories.assignment.notification.link",
                :user => fb_name(user, :linked => false, :firstnameonly => true, :useyou => false)
              )
            ) + " &raquo;", relations_url
          )
        )
      )
    end
  end
end