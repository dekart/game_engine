class CharacterStatusController < ActionController::Metal
  def show
    begin
      signed_request = request.env['HTTP_SIGNED_REQUEST'] || session["fb_signed_request_#{ Facepalm::Config.default.app_id }"]

      if facebook_user = Facepalm::User.from_signed_request(Facepalm::Config.default, signed_request)
        user = User.find_by_facebook_id(facebook_user.uid)

        if user and user.admin? and user.simulation
          user = user.simulation.user
        end
      end

      self.content_type = Mime::JSON
      self.response_body = (user ? user.character.to_json_for_overview : {}.to_json)
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
