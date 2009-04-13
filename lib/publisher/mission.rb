module Publisher
  class Mission < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def completed_template
      one_line_story_template "{*actor*} completed \"{*mission_name*}\" mission in #{link_to(fb_app_name, "{*mission_url*}")} game!"
      short_story_template(
        "{*actor*} received \"{*title*}\" title in #{link_to(fb_app_name, "{*mission_url*}")} game!",
        "{**} completed \"{*mission*}\" mission and received \"{*title*}\" title in #{link_to(fb_app_name, "{*mission_url*}")} game."
      )
    end
  end
end