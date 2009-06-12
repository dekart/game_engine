module Publisher
  class Mission < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def completed_template
      one_line_story_template "{*actor*} " + fb_i(
        I18n.t("stories.mission.one_line") +
        fb_it(:app, link_to(fb_app_name, root_url(:canvas => true)))
      )
      short_story_template(
        fb_i(I18n.t("stories.mission.short.title") + fb_it(:app, link_to(fb_app_name, root_url(:canvas => true)))),
        fb_i(I18n.t("stories.mission.short.text") + fb_it(:app, link_to(fb_app_name, root_url(:canvas => true))))
      )
      action_links(
        action_link(
          fb_i(I18n.t("stories.mission.action_link") + fb_it(:app, fb_app_name(:linked => false))) + " &raquo;",
          root_url
        )
      )
    end
  end
end