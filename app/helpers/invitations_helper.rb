module InvitationsHelper
  def invitation_short_url(character)
    if Setting.b(:invitation_direct_link)
      "%s/cil/%s" % [
        Facebooker.facebooker_config['callback_url'],
        character.invitation_key
      ]
    else
      "http://%s%s/cil/%s" % [
        Facebooker.canvas_server_base,
        Facebooker.facebook_path_prefix,
        character.invitation_key
      ]
    end
  end
end
