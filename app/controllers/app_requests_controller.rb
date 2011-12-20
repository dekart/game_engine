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
    
    if @next_page = page_for_redirect
      redirect_from_iframe(@next_page)
    else  
      render :layout => 'ajax'
    end  
  end
  
  def ignore
    @app_request = current_character.app_requests.find(params[:id])
    
    @app_request.ignore
    
    render :layout => 'ajax'
  end
  
  protected
  
  def page_for_redirect
    case @app_request.type_name
    when 'monster_invite'
      url = monster_url(@app_request.monster, 
        :key => encryptor.encrypt(@app_request.monster.id), 
        :canvas => true
      )
    when 'clan_invite'
      clan_path(@app_request.sender.clan, :canvas => true)
    else
      false
    end
  end
end
