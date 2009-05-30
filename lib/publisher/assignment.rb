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
      fbml "promoted you as #{fb_pronoun(user, :possessive => true)} <b>#{I18n.t("assignments.roles.#{assignment.role}.title")}</b> in #{link_to(fb_app_name(:linked => false), root_url)}! #{link_to("Promote #{fb_name(user, :linked => false, :firstnameonly => true)} &raquo;", relations_url)}"
    end
  end
end