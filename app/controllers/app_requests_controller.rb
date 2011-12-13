class AppRequestsController < ApplicationController
  skip_authentication_filters :only => :create
  skip_before_filter :tracking_requests, :only => :create
  
  def index
    @app_requests = current_character.app_requests.visible.all(:order => "sender_id, type, created_at DESC")
  end
  
  def create
    @request_type = params[:type]
    
    if params[:target_id] && params[:target_type]
      @target = params[:target_type].constantize.find(params[:target_id])
    end
    
    @recipients = Array.wrap(params[:to])

    @recipients.each do |recipient_id|
      AppRequest::Base.create(:facebook_id => params[:request_id], :receiver_id => recipient_id)
    end

    render :layout => 'ajax'
  end
  
  def update
    @app_request = current_character.app_requests.find(params[:id])

    @app_request.accept
      
    render :layout => 'ajax'
  end
  
  def ignore
    @app_request = current_character.app_requests.find(params[:id])
    
    @app_request.ignore
    
    render :layout => 'ajax'
  end
end
