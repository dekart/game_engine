class CharacterStatus
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/character_status/ and facebook_session = env['rack.session'][:facebook_session]
      if character = User.find_by_facebook_id(facebook_session.user.id).try(:character)
        [200, {"Content-Type" => "application/json"}, character.to_json_for_overview]
      else
        [404, {"Content-Type" => "text/html"}, "Not Found"]
      end
    else
      [404, {"Content-Type" => "text/html"}, "Not Found"]
    end
  ensure
    ActiveRecord::Base.clear_active_connections!
  end
end
