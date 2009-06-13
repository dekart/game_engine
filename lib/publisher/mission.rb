module Publisher
  class Mission < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def completed_template
      one_line_story_template I18n.t("stories.mission.one_line",
        :app => link_to(fb_app_name, root_url(:canvas => true))
      )
      short_story_template(
        I18n.t("stories.mission.short.title", :app => link_to(fb_app_name, root_url(:canvas => true))),
        I18n.t("stories.mission.short.text", :app => link_to(fb_app_name, root_url(:canvas => true)))
      )
      action_links(
        action_link(
          I18n.t("stories.mission.action_link", :app => link_to(fb_app_name, root_url(:canvas => true))),
          root_url
        )
      )
    end
  end
end