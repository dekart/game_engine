module Publisher
  class Mission < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def completed_template
      one_line_story_template "{*actor*} completed \"{*mission*}\" mission in #{link_to(fb_app_name, root_url(:canvas => true))} game!"
      short_story_template(
        "{*actor*} received \"{*title*}\" title in #{link_to(fb_app_name, root_url(:canvas => true))} game!",
        "{*actor*} completed \"{*mission*}\" mission and received \"{*title*}\" title in #{link_to(fb_app_name, root_url(:canvas => true))} game."
      )
      action_links(
        action_link("Play #{fb_app_name(:linked => false)} &raquo;", root_url)
      )
    end
  end
end