module HelpRequestsHelper
  def help_request_link(label, mission, options = {})
    link_to_function(label, help_request_dialog(mission), options) if current_character.help_requests.can_publish?
  end

  def help_request_dialog(mission)
    help_url = help_request_url(current_character, :canvas => true)

    show_feed_dialog(Publisher::HelpRequest, :request,
      :template_data => {
        :mission => mission.name,
        :app => link_to(fb_app_name(:linked => false), help_url),
        :help_url => help_url
      },
      :image_url => help_url,
      :continuation => "HelpRequest.create(#{mission.id})"
    )
  end
end
