class ShortLinksController < ActionController::Metal
  include ActionController::Rendering
  include ActionController::Redirecting
  include AbstractController::Helpers
  include ApplicationController::ReferenceCode
  include Facepalm::Rails::Controller::Redirects
  
  def facepalm
    Facepalm::Config.default
  end
  
  def show
    key = params[:key]
    
    begin
      target_url = facepalm.canvas_page_url("#{ env['rack.url_scheme'] }://")

      if user_id = Character.find_by_invitation_key(key).try(:user_id)
        target_url << "/relations/%s?reference_code=%s" % [key, Rack::Utils.escape(reference_code(:invite_link, user_id))]
      end
      
      custom_headers = %{
        <meta property="og:site_name" content="#{ I18n.t("app_name") }"/>
        <meta property="og:type" content="game"/>
        <meta property="og:image" content="#{ view_context.image_path('logo_stream.jpg') }"/>
        <meta property="og:title" content="#{ I18n.t("relations.short_link.title", :app => I18n.t("app_name")) }"/>
        <meta property="og:description" content="#{ I18n.t("relations.short_link.description", :app => I18n.t("app_name")) }"/>

        <meta property="fb:app_id" content="#{ facepalm.app_id }" />
        <meta property="fb:admins" content="#{ Setting.a(:user_admins).join(',') }" />
      }
      
      self.content_type = Mime::HTML
      self.response_body = iframe_redirect_code(target_url, custom_headers)
    rescue Exception => e
      #TODO Possibly this rescue is not necessary. Remove it if there will be no errors.
      Rails.logger.error "Failed to parse short link: '#{ env["PATH_INFO"] }'"
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")

      self.content_type = Mime::HTML
      self.response_body = iframe_redirect_code(facepalm.canvas_page_url('http://'))
    end
  end
end
