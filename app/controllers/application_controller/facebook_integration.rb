require 'facepalm/rails/controller'

class ApplicationController
  module FacebookIntegration
    def self.included(base)
      base.class_eval do
        include Facepalm::Rails::Controller
        
        helper Facepalm::Rails::Helpers::JavascriptHelper
        
        facepalm_authentication(:email) unless ENV['OFFLINE']
        
        rescue_from Facepalm::OAuthException, :with => :rescue_facebook_oauth_exception
      end
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