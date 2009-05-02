class CharacterStatus
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/character_status/
      request = Rack::Request.new(env)

      if user = User.find_by_facebook_id(request.params["fb_sig_user"])
        [200, {"Content-Type" => "application/json"}, user.character.to_json]
      else
        [404, {"Content-Type" => "text/html"}, "Not Found"]
      end
    else
      [404, {"Content-Type" => "text/html"}, "Not Found"]
    end
  end
end
