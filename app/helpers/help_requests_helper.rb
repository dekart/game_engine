module HelpRequestsHelper
  def help_request_link(label, context, options = {})
    link_to_function(label, help_request_dialog(context), options) #if current_character.help_requests.can_publish?(context)
  end

  def help_request_dialog(context)
    context_type = context.class.to_s.underscore

    help_url = help_request_url(current_character, :context => context_type, :canvas => true)

    case context
    when Fight
      attachment = {
        :caption => t("stories.help_request.fight.title", :level => context.victim.level, :app => t("app_name"))
      }
    when Mission
      attachment = {
        :caption      => t("stories.help_request.mission.title", :mission => context.name, :app => t("app_name")),
        :description  => t("stories.help_request.mission.description")
      }
    end

    show_stream_dialog(
      :attachment => attachment,
      :action_links => [
        {
          :text => t("stories.help_request.action_link"),
          :href => help_url
        }
      ],
      :success => "HelpRequest.create(#{context.id}, '#{context_type}')"
    )
  end
end
