module HelpRequestsHelper
  def help_request_link(label, context, options = {})
    if current_character.help_requests.can_publish?(context)
      link_to_function(label, help_request_stream_dialog(context), options)
    end
  end
end
