class CharacterStatusController < ActionController::Metal
  def show
    begin
      signed_request = request.env['HTTP_SIGNED_REQUEST'] || session["fb_signed_request_#{ Facepalm::Config.default.app_id }"]
      
      facebook_user = Facepalm::User.from_signed_request(Facepalm::Config.default, signed_request)
      character = User.find_by_facebook_id(facebook_user.uid).try(:character) if facebook_user
      
      self.content_type = Mime::JSON
      self.response_body = (character ? character.to_json_for_overview : {}.to_json) 
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
