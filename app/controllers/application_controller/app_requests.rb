class ApplicationController
  module AppRequests
    def self.included(base)
      base.class_eval do
        helper_method :visit_from_app_request?
      end
    end

    protected

    def app_request_ids
      params[:request_ids].present? ? params[:request_ids].split(',').collect{|v| v.to_i } : []
    end

    def visit_from_app_request?
      !app_request_ids.empty?
    end

    def visit_from_bookmark_counter?
      params[:ref] == 'bookmarks' && params[:count].to_i > 0
    end

    def app_requests
      @app_requests_from_params ||= visit_from_app_request? ? AppRequest::Base.with_state(:processed).find_all_by_facebook_id(app_request_ids) : []
    end

    def check_user_app_requests
      if visit_from_app_request? || visit_from_bookmark_counter?
        Delayed::Job.enqueue Jobs::UserRequestCheck.new(current_user.id)
      end

      yield

      app_requests.each do |r|
        r.visit
      end
    end
  end
end