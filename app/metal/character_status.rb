class CharacterStatus
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/character_status\/(\d+-[a-z0-9]+)/
      Rails.logger.debug "Character status check: #{$1}"

      if character = Character.find_by_key($1)
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
