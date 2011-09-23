class CharacterStatus
  extend FacebookSignedRequest
  
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/character_status/
      request = Rack::Request.new(env)
      
      if character = extract_character(request)
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
