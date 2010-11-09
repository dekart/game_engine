class ApplicationController
  module ExceptionLogging
    def self.included(base)
      {
        Exception                             => :rescue_basic_exception,
        ActionController::MethodNotAllowed    => :rescue_method_not_allowed,
        ActionController::RoutingError        => :rescue_routing_error,
        ActionController::UnknownAction       => :rescue_unknown_action,
        ActiveRecord::StaleObjectError        => :rescue_locking_error,
        Facebooker2::OAuthException           => :rescue_facebooker_oauth_exception
      }.each do |exception, method|
        base.rescue_from(exception, :with => method)
      end
    end

    def rescue_basic_exception(exception)
      fatal_log_processing_for_request_id
      fatal_log_processing_for_parameters

      log_error(exception)

      log_browser_info

      redirect_to root_url
    end

    def rescue_method_not_allowed(exception)
      logger.fatal("Method not allowed for #{request.request_uri} [#{request.method.to_s.upcase}]")
      logger.fatal(exception)

      log_browser_info

      redirect_to root_url
    end

    def rescue_routing_error(exception)
      logger.fatal(exception)

      log_browser_info

      redirect_to root_url
    end

    def rescue_unknown_action(exception)
      logger.fatal("Unknown action for #{request.request_uri} [#{request.method.to_s.upcase}]")
      fatal_log_processing_for_parameters

      log_error(exception)

      log_browser_info

      redirect_to root_url
    end

    # TODO: Catch locking error in models that may cause them instead of controller
    def rescue_locking_error(exception)
      render :text => ""
    end

    def rescue_facebooker_oauth_exception
      logger.fatal(exception)

      log_browser_info

      redirect_to root_url
    end

    def fatal_log_processing_for_request_id
      request_id = "\n\nProcessing #{self.class.name}\##{action_name} "
      request_id << "to #{params[:format]} " if params[:format]
      request_id << "(for #{request_origin}) [#{request.method.to_s.upcase}]"

      logger.fatal(request_id)
    end

    def fatal_log_processing_for_parameters
      parameters = respond_to?(:filter_parameters) ? filter_parameters(params.dup) : params.dup
      parameters = parameters.except!(:controller, :action, :format, :_method)

      logger.fatal "  Parameters: #{parameters.inspect}" unless parameters.empty?
    end

    def log_browser_info
      logger.fatal "Requested URL: #{request.url}"
      logger.fatal "Referer: #{request.headers["Referer"]}" unless request.headers["Referer"].blank?
      logger.fatal "Request Origin: #{request_origin}"
      logger.fatal "User Agent: #{request.headers["User-Agent"]}\n\n"
    end
  end
end
