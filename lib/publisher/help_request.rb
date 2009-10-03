module Publisher
  class HelpRequest < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end

    include FacebookHelper

    def self.template_data_for(context)
      if context.is_a?(::Fight)
        {:level => context.victim.level}
      else
        {:mission => context.name}
      end
    end

    def mission_template
      one_line_story_template I18n.t("stories.help_request.mission.one_line")
      short_story_template(
        I18n.t("stories.help_request.mission.short.title"),
        I18n.t("stories.help_request.mission.short.text")
      )
      action_links(
        action_link(I18n.t("stories.help_request.mission.short.link"), "{*help_url*}")
      )
    end
    
    def fight_template
      one_line_story_template I18n.t("stories.help_request.fight.one_line")
      short_story_template(
        I18n.t("stories.help_request.fight.short.title"),
        I18n.t("stories.help_request.fight.short.text")
      )
      action_links(
        action_link(I18n.t("stories.help_request.fight.short.link"), "{*help_url*}")
      )
    end
  end
end