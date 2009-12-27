module InvitationsHelper
  def invitation_stream_dialog
    show_stream_dialog(
      :attachment => {
        :caption => t("stories.invitation.title", :app => t("app_name")),
        :description => t("stories.invitation.description", :app => t("app_name")),
        :media => default_stream_media(
          invitation_url(current_character.invitation_key, :reference => :invite_stream_image)
        )
      },
      :action_links => [
        {
          :text => t("stories.invitation.action_link"),
          :href => invitation_url(current_character.invitation_key, :reference => :invite_stream_link)
        }
      ]
    )
  end
end
