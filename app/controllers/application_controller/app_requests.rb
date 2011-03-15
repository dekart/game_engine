class ApplicationController
  module AppRequests
    def self.included(base)
      base.after_filter :visit_user_app_requests
    end
    
    def app_requests
      params[:request_ids].present? ? AppRequest::Base.find_all_by_facebook_id(params[:request_ids].split(',')) : []
    end
    
    def redirect_by_app_request
      puts app_requests.inspect
      if app_requests.last
        session[:return_to] = nil

        redirect_back app_requests_url(:canvas => true)
      end
    end

    def visit_user_app_requests
      app_requests.map{|r| r.visit }
    end
  end
end