# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionLogging
  include FacebookIntegration
  include LandingPage
  include ReferenceCode

  before_filter :check_character_existance, :except => [:facebook_oauth_connect]
  facebook_integration_filters
  before_filter :redirect_by_request
  after_filter :accept_used_app_requests
  
  landing_redirect

  layout :get_layout

  helper_method :current_user, :current_character, :current_skin

  helper :all

  protected

  def check_character_existance
    unless current_character
      store_return_to

      url_params = params.to_hash.symbolize_keys
      url_params.merge!(
        :controller => "/characters",
        :action     => :new,
        :id         => nil,
        :canvas     => true
      )

      redirect_from_iframe url_for(url_params)
    end
  end

  def current_character(force_reload = false)
    if current_user.nil?
      @current_character = nil
    elsif force_reload || @current_character.nil?
      @current_character = current_user.character(force_reload)
    end

    @current_character
  end

  def current_user
    if current_facebook_user
      @current_user ||= find_or_create_current_user
    end
  end

  def find_or_create_current_user
    facebook_id = current_facebook_user.id

    unless user = User.find_by_facebook_id(facebook_id)
      user = User.new
      
      user.facebook_id  = facebook_id
      user.signup_ip    = request.remote_ip

      if reference_data
        user.reference    = reference_data[0]
        user.referrer_id  = reference_data[1]
      elsif requests = app_requests and !requests.empty?
        user.reference  = requests.last.reference || 'request'
        user.referrer   = requests.last.try(:sender)
      elsif params[:reference]
        user.reference = params[:reference]
      end
    end

    # Updating user access information
    user.access_token = current_facebook_user.client.access_token
    user.access_token_expire_at = current_facebook_user.client.expiration
    
    user.last_visit_at = Time.now if user.last_visit_at.nil? || user.last_visit_at < 30.minutes.ago
    user.last_visit_ip = request.remote_ip
    
    user.save!

    user
  end

  def default_url_options(options = {})
    options[:try_skin] = params[:try_skin] unless params[:try_skin].blank?
    options
  end

  def get_layout
    (current_character.nil? || current_character.new_record?) ? "unauthorized" : "application"
  end

  def current_skin
    params[:try_skin] ? Skin.find_by_id(params[:try_skin]) : Skin.with_state(:active).first
  end

  def store_return_to(uri = nil)
    session[:return_to] = uri
    session[:return_to] ||= params[:return_to]
    session[:return_to] ||= url_for(params_without_facebook_data.merge(:canvas => true))
  end

  def redirect_back(uri)
    if session[:return_to].present?
      uri = session[:return_to]

      session[:return_to] = nil
    end
    
    redirect_from_iframe(uri)
  end
  
  def redirect_by_request
    if app_requests.last and url = app_requests.last.return_to
      session[:return_to] = nil
      
      redirect_back(url)
    end
  end
    
  def accept_used_app_requests
    app_requests.map{|r| r.accept }
  end

  def app_requests
    params[:request_ids].present? ? AppRequest.find_all_by_facebook_id(params[:request_ids].split(',')) : []
  end
end
