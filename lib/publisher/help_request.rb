module Publisher
  class HelpRequest < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def request_template
      one_line_story_template I18n.t("stories.help_request.one_line")
      short_story_template(
        I18n.t("stories.help_request.short.title"),
        I18n.t("stories.help_request.short.text")
      )
      action_links(
        action_link(I18n.t("stories.help_request.short.link"), "{*help_url*}")
      )
    end
  end
end