module Publisher
  class Item < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def bought_template
      one_line_story_template "{*actor*} " + fb_i(
        I18n.t("stories.item.one_line") +
        fb_it(:app, link_to(fb_app_name, root_url(:canvas => true)))
      )
      short_story_template(
        fb_i(I18n.t("stories.item.short.title") + fb_it(:app, link_to(fb_app_name, root_url(:canvas => true)))),
        fb_i(I18n.t("stories.item.short.text") + fb_it(:app, link_to(fb_app_name, root_url(:canvas => true))))
      )
      action_links(
        action_link(
          fb_i(I18n.t("stories.item.action_link") + fb_it(:app, fb_app_name(:linked => false))) + " &raquo;",
          root_url
        )
      )
    end
  end
end