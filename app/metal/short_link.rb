class ShortLink
  extend ApplicationController::ReferenceCode
  extend Facepalm::Rails::Controller::Redirects
  
  class << self
    # Required for reference code parsing
    def facepalm
      Facepalm::Config.default
    end
    
    def call(env)
      match_data = env["PATH_INFO"].match(/^\/cil\/(\d+-[a-z0-9]+)/)
    
      if match_data and key = match_data[1]
        target_url = facepalm.canvas_page_url("#{ env['rack.url_scheme'] }://")

        if user_id = Character.find_by_invitation_key(key).try(:user_id)
          target_url << "/relations/%s?reference_code=%s" % [key, Rack::Utils.escape(reference_code(:invite_link, user_id))]
        end
      
        [200, {"Content-Type" => "text/html"}, iframe_redirect_code(target_url)]
      else
        [404, {"Content-Type" => "text/html"}, "Not Found"]
      end
    rescue Exception => e
      #TODO Possibly this rescue is not necessary. Remove it if there will be no errors.
      Rails.logger.error "Failed to parse short link: '#{ env["PATH_INFO"] }'"
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")

      [200, {"Content-Type" => "text/html"}, iframe_redirect_code(facepalm.canvas_page_url('http://'))]
    end
  end
end
