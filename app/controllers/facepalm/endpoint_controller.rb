require_dependency Facepalm::Engine.root.join('app', 'controllers', 'facepalm', 'endpoint_controller').to_s

class Facepalm::EndpointController
  rescue_from Facepalm::OAuthException, :with => :rescue_facebook_oauth_exception

  def rescue_facebook_oauth_exception(exception)
    if params[:error_reason] == 'user_denied' and HelpPage.visible?(:permissions)
      redirect_to help_page_url(:permissions)
    else
      logger.fatal(exception)

      log_browser_info

      redirect_to root_url
    end
  end
end