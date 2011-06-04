module RelationsHelper
  def invitation_short_url(character)
    "%s/cil/%s" % [
      Setting.b(:invitation_direct_link) ? facebook_callback_url : facebook_canvas_page_url,
      character.invitation_key
    ]
  end
end
