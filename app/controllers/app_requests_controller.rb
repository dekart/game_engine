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

    @recipients.each do |recipient_id|
      AppRequest::Base.create(:facebook_id => params[:request_id], :receiver_id => recipient_id)
    end
  end
  
  def update
    @app_request = current_character.app_requests.find(params[:id])

    @app_request.accept
    
    if @next_page = page_for_redirect
      redirect_to @next_page
    end  
  end
  
  def ignore
    @app_request = current_character.app_requests.find(params[:id])
    
    @app_request.ignore
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

    response = {
      :exclude_ids => { invite_type.to_sym => ids },
      :dialog_template => render("invite_dialog.json").first
    }

    self.content_type = Mime::JSON
    self.response_body = response.to_json
  end

  protected
  
  def page_for_redirect
    case @app_request
    when AppRequest::MonsterInvite
      monster_url(@app_request.monster, 
        :key => encryptor.encrypt(@app_request.monster.id), 
        :canvas => true
      )
    when AppRequest::ClanInvite
      clan_url(@app_request.sender.clan, :canvas => true)
    else
      false
    end
  end
end
