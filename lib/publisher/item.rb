module Publisher
  class Item < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def bought_template
      one_line_story_template I18n.t("stories.item.one_line", 
        :app => link_to(fb_app_name, root_url(:canvas => true))
      )
      short_story_template(
        I18n.t("stories.item.short.title", :app => link_to(fb_app_name, root_url(:canvas => true))),
        I18n.t("stories.item.short.text", :app => link_to(fb_app_name, root_url(:canvas => true)))
      )
      action_links(
        action_link(
          I18n.t("stories.item.action_link", :app => link_to(fb_app_name, root_url(:canvas => true))),
          root_url
        )
      )
    end
  end
end