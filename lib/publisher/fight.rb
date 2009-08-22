module Publisher
  class Fight < Facebooker::Rails::Publisher
    self.master_helper_module.module_eval do
      include ::ApplicationHelper
      include ::FacebookHelper
    end
    
    include FacebookHelper

    def notification(user, fight)
      send_as :notification
      recipients fight.victim.user
      from user
      fbml fb_i(
        I18n.t("stories.fight.notification.text") +
        fb_it(:app, link_to(fb_app_name(:linked => false), root_url)) +
        fb_it(:link, 
          link_to(fb_i(I18n.t('stories.fight.notification.link')) + " &raquo;", character_url(fight.attacker))
        )
      )
    end

    def invitation(user, victim)
      send_as :notification
      recipients victim
      from user
      fbml fb_i(
        I18n.t("stories.fight.invitation.text") +
        fb_it(:app, link_to(fb_app_name(:linked => false), root_url)) +
        fb_it(:link,
          link_to(fb_i(I18n.t('stories.fight.invitation.link')), root_url)
        )
      )
    end

    def attack_template
      one_line_story_template I18n.t("stories.fight.one_line", 
        :app => link_to(fb_app_name(:linked => false), root_url)
      )
      short_story_template(
        I18n.t("stories.fight.short.title", :app => link_to(fb_app_name(:linked => false), root_url)),
        I18n.t("stories.fight.short.text")
      )
      action_links(
        action_link(
          I18n.t("stories.fight.action_link", :app => fb_app_name(:linked => false)),
          root_url
        )
      )
    end
  end
end