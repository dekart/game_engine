module Publisher
  class Assignment < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def notification(assignment)
      Facebooker::Session.create.post("facebook.dashboard.addNews",
        :uid => assignment.relation.character.user.facebook_id,
        :news => [
          {
            :message => I18n.t("news.assignment.text",
              :user => "@:#{assignment.context.user.facebook_id}",
              :position => I18n.t("assignments.roles.#{assignment.role}.title")
            ),
            :action_link => {
              :text => I18n.t("news.assignment.link"),
              :href => relations_url
            }
          }
        ]
      )
    end
  end
end
