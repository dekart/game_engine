module Publisher
  class Item < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def bought_template
      one_line_story_template "{*actor*} bought {*item*} in #{link_to(fb_app_name, root_url(:canvas => true))}"
      short_story_template(
        "{*actor*} bought new item in #{link_to(fb_app_name, root_url(:canvas => true))}",
        "{*actor*} bought {*item*} in #{link_to(fb_app_name, root_url(:canvas => true))}. Now {*actor*} is stronger than before!"
      )
      action_links(
        action_link("Play #{fb_app_name(:linked => false)} &raquo;", root_url)
      )
    end
  end
end