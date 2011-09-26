class CharacterStatus
  class << self
    def call(env)
      if env["PATH_INFO"] =~ /^\/character_status/
        request = Rack::Request.new(env)
      
        facebook_user = Facepalm::User.from_signed_request(Facepalm::Config.default, request.env['HTTP_SIGNED_REQUEST']) 
        
        if facebook_user and character = User.find_by_facebook_id(facebook_user.uid).try(:character)
          [200, {"Content-Type" => "application/json"}, character.to_json_for_overview]
        else
          [200, {"Content-Type" => "application/json"}, {}.to_json]
        end
      else
        [404, {"Content-Type" => "text/html"}, "Not Found"]
      end
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
