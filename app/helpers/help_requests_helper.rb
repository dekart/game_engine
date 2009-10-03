module HelpRequestsHelper
  def help_request_link(label, context, options = {})
    link_to_function(label, help_request_dialog(context), options) if current_character.help_requests.can_publish?(context)
  end

  def help_request_dialog(context)
    context_type = context.class.to_s.underscore

    help_url = help_request_url(current_character, :context => context_type, :canvas => true)

    show_feed_dialog(Publisher::HelpRequest, context_type.to_sym,
      :template_data => Publisher::HelpRequest.template_data_for(context).merge(
        :app => link_to(fb_app_name(:linked => false), help_url),
        :help_url => help_url
      ),
      :image_url => help_url,
      :continuation => "HelpRequest.create(#{context.id}, '#{context_type}')"
    )
  end
end
