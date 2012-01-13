require 'facepalm'

class ShortLink
  extend ApplicationController::ReferenceCode
  extend Facepalm::Rails::Controller::Redirects
  extend ActionView::Helpers::AssetTagHelper 
  extend AssetsHelper
  
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
        
        custom_headers = %{
          <meta property="og:site_name" content="#{ I18n.t("app_name") }"/>
          <meta property="og:type" content="game"/>
          <meta property="og:image" content="#{ asset_image_path(:logo_stream) }"/>
          <meta property="og:title" content="#{ I18n.t("relations.short_link.title", :app => I18n.t("app_name")) }"/>
          <meta property="og:description" content="#{ I18n.t("relations.short_link.description", :app => I18n.t("app_name")) }"/>

          <meta property="fb:app_id" content="#{ facepalm.app_id }" />
          <meta property="fb:admins" content="#{ Setting.a(:user_admins).join(',') }" />
        }
      
        [200, {"Content-Type" => "text/html"}, iframe_redirect_code(target_url, custom_headers)]
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
