class AppRequestsController < ApplicationController
  skip_authentication_filters :only => :create
  skip_before_filter :tracking_requests, :only => :create

  def index
    respond_to do |format|
      format.json do
        render :json => current_character.app_requests.as_json
      end
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
      format.json do
        render :json => {
          :type   => @request_type.titleize,
          :target => @target,
          :count  => @recipients.size
        }
      end
    end
  end

  def accept
    @app_requests = current_character.app_requests.all.find(params[:ids].split(','))

    AppRequest::Base.transaction do
      @app_requests.each do |r|
        r.accept
      end
    end

    respond_to do |format|
      format.json do
        render :json => {
          :type => @app_requests.first.type_name.titleize,
          :target => @app_requests.first.target,
          :count => @app_requests.size,
          :next_page => page_for_redirect(@app_requests.first)
        }
      end
    end
  end

  def ignore
    @app_requests = current_character.app_requests.all.find(params[:ids].split(','))

    AppRequest::Base.transaction do
      @app_requests.each do |r|
        r.ignore
      end
    end

    respond_to do |format|
      format.json do
        render :json => {
          :success => true
        }
      end
    end
  end

  def invite
    invite_type = params[:type]

    ids = case invite_type
      when "clan_invite"
        AppRequest::ClanInvite.ids_to_exclude_for(current_character)
      when "invitation"
        AppRequest::Invitation.ids_to_exclude_for(current_character)
      when "gift"
        AppRequest::Gift.ids_to_exclude_for(current_character)
      when "property_worker"
        AppRequest::PropertyWorker.ids_to_exclude_for(current_character)
      else
        []
      end

    render :json => {
      :exclude_ids  => ids
    }
  end

  protected

  def page_for_redirect(app_request)
    case app_request
    when AppRequest::MonsterInvite
      monster_path(app_request.monster,
        :key => encryptor.encrypt(app_request.monster.id)
      )
    when AppRequest::ClanInvite
      clan_path(app_request.sender.clan)
    else
      false
    end
  end
end
