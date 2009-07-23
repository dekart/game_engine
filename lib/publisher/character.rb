module Publisher
  class Character < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def level_up_template
      one_line_story_template I18n.t("stories.character.level_up.one_line",
        :app => link_to(fb_app_name, root_url(:canvas => true))
      )
      short_story_template(
        I18n.t("stories.character.level_up.short.title", :app => link_to(fb_app_name, root_url(:canvas => true))),
        I18n.t("stories.character.level_up.short.text", :app => link_to(fb_app_name, root_url(:canvas => true)))
      )
      action_links(
        action_link(
          I18n.t("stories.character.level_up.action_link", :app => link_to(fb_app_name, root_url(:canvas => true))),
          root_url
        )
      )
    end
  end
end