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
        redirect_from_iframe help_page_url(:permissions, :canvas => true)
      else
        logger.fatal(exception)

        log_browser_info

        redirect_from_iframe root_url(:canvas => true)
      end
    end
  end
end