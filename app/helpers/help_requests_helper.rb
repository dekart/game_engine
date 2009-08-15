module HelpRequestsHelper
  def help_request_link(label, mission, options = {})
    link_to_function(label, help_request_dialog(mission), options) if current_character.help_requests.can_publish?
  end

  def help_request_dialog(mission)
    help_link = help_request_url(current_character, :canvas => true)

    show_feed_dialog(Publisher::HelpRequest, :request,
      :template_data => {
        :mission => mission.name,
        :app => link_to(fb_app_name(:linked => false), help_link)
      },
      :body_general => content_tag(:b,
        link_to(
          t("stories.help_request.help_link", 
            :user => fb_name(current_user,
              :linked         => false,
              :use_you        => false,
              :firstnameonly  => true
            )
          ),
          help_link
        )
      ),
      :image_url => help_link,
      :continuation => "HelpRequest.create(#{mission.id})"
    )
  end
end
