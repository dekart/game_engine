module HelpRequestsHelper
  def help_request_link(label, context, options = {})
    if current_character.help_requests.can_publish?(context)
      link_to_function(label, help_request_stream_dialog(context), options)
    end
  end

  def latest_help_request_for(context)
    help_request = current_character.help_requests.latest(:mission)

    if help_request.try(:should_be_displayed?)
      render("help_requests/latest",
        :help_request => help_request,
        :context      => context
      )
    end
  end
end
