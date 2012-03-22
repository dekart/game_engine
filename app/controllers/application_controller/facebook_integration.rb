class ApplicationController
  module FacebookIntegration
    def self.included(base)
      base.class_eval do
        before_filter(:require_facebook_permissions) unless ENV['OFFLINE']

        rescue_from Facepalm::OAuthException, :with => :rescue_facebook_oauth_exception
      end
    end

    def require_facebook_permissions
      facepalm_require_authentication(:email, :publish_actions)
    end
  
    def rescue_facebook_oauth_exception(exception)
      if params[:error_reason] == 'user_denied' and HelpPage.visible?(:permissions)
        redirect_to help_page_url(:permissions)
      else
        logger.fatal(exception)

        log_browser_info

        redirect_to root_url
      end
    end
    
    def fb_sighed_request_session
      "fb_signed_request_#{ facepalm.app_id }"
    end
    
    # redefining facepalm methods
  
    def fb_signed_request
      super || session[fb_sighed_request_session]
    end
    
    def facepalm_auth_return_code
      facepalm_url_encryptor.encrypt(
        url_for(params_without_facebook_data.merge(:canvas => false, :only_path => true, :from_canvas => fb_canvas?))
      )
    end
  end
end