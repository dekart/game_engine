class AppRequestsController < ApplicationController
  skip_authentication_filters :only => :create
  skip_before_filter :tracking_requests, :only => :create
  
  def index
    @app_requests_types = current_character.app_requests.visible.types
    
    @current_type = AppRequest::Base.find_by_facebook_id(params[:app_request_id]).try(:type_name) if params[:app_request_id]
    @current_type ||= params[:type]
    @current_type ||= @app_requests_types.first[:name] if @app_requests_types.present?
    
    @app_requests = @current_type ? current_character.app_requests.visible.by_type(@current_type) : []                                               
                                                   
    if request.xhr?
      render(
        :partial => "list",
        :locals => {:app_requests => @app_requests},
        :layout => false
      )
    end                                                                  
  end
  
  def create
    @request_type = params[:type]
    
    if params[:target_id] && params[:target_type]
      @target = params[:target_type].constantize.find(params[:target_id])
    end
    
    @recipients = Array.wrap(params[:to])

    Delayed::Job.enqueue Jobs::RequestDataUpdate.new(params[:request_id], @recipients)

    respond_to do |format|
      format.js
    end
  end
  
  def update
    @app_request = current_character.app_requests.find(params[:id])

    @app_request.accept
    
    @next_page = page_for_redirect

    respond_to do |format|
      format.js
    end
  end
  
  def ignore
    @app_request = current_character.app_requests.find(params[:id])
    
    @app_request.ignore

    respond_to do |format|
      format.js
    end
  end

  def invite
    invite_type = params[:type]
    ids = []

    case invite_type
    when "clan_invite"
      ids = AppRequest::ClanInvite.ids_to_exclude_for(current_character)
    when "invitation"
      ids = AppRequest::Invitation.ids_to_exclude_for(current_character)
    when "gift"
      ids = AppRequest::Gift.ids_to_exclude_for(current_character)
    when "property_worker"
      ids = AppRequest::PropertyWorker.ids_to_exclude_for(current_character)
    end

    render :json => {
      :exclude_ids  => ids
    }
  end

  protected

  def page_for_redirect
    case @app_request
    when AppRequest::MonsterInvite
      monster_path(@app_request.monster,
        :key => encryptor.encrypt(@app_request.monster.id)
      )
    when AppRequest::ClanInvite
      clan_path(@app_request.sender.clan)
    else
      false
    end
  end
end
