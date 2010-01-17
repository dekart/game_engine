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
      fbml I18n.t("notifications.assignment.text",
        :pronoun  => fb_pronoun(user, :possessive => true, :useyou => false),
        :title    => content_tag(:b, I18n.t("assignments.roles.#{assignment.role}.title")),
        :app      => link_to(fb_app_name(:linked => false), root_url),
        :link     => link_to(
          I18n.t("notifications.assignment.link",
            :user => fb_name(user, :linked => false, :firstnameonly => true, :useyou => false)
          ),
          relations_url
        )
      )
    end
  end
end