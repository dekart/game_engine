# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionLogging
  include FacebookIntegration
  include TrackingRequests
  include ReferenceCode
  include AppRequests
  include Notifications

  before_filter :check_standalone

  before_filter :check_character_existance
  before_filter :check_user_ban
  
  layout :get_layout

  helper_method :current_user, :current_character, :special_items

  helper :all

  protected
  
  def special_items
    @special_items ||= Item.special_for(current_character).all(
      :limit => Setting.i(:item_show_special),
      :order => 'RAND()'
    )
  end
  
  def self.skip_authentication_filters(options = {})
    skip_before_filter(:check_character_existance, :check_user_ban, :require_facebook_permissions, options)
  end
  
  def check_character_existance
    Rails.logger.debug "check_character_existance: fb_canvas? = #{fb_canvas?}"
    puts "check_character_existance: fb_canvas? = #{fb_canvas?}"
    
    unless current_character
      store_return_to

      #url_params = params_without_facebook_data.to_hash.symbolize_keys
      url_params = params.to_hash.symbolize_keys
      url_params.merge!(
        :controller => "/characters",
        :action     => :new,
        :id         => nil
      )
Rails.logger.debug "check_character_existance: url_params = #{url_params.inspect}"
      redirect_to url_for(url_params)
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
    return unless current_facebook_user
    
    if current_facebook_user.authenticated?
      @current_user ||= find_or_create_current_user
    elsif ENV['OFFLINE']
      @current_user ||= find_or_create_offline_user
    end
  end

  def find_or_create_current_user
    facebook_id = current_facebook_user.uid

    unless user = User.find_by_facebook_id(facebook_id)
      user = User.new
      
      user.facebook_id  = facebook_id
      user.signup_ip    = request.remote_ip

      if reference_data
        user.reference    = reference_data[0]
        user.referrer_id  = reference_data[1]
      elsif app_request = app_requests.last
        user.reference  = app_request.type_name
        user.referrer   = app_request.sender.try(:user)
      else
        user.reference = reference_key
      end
    end

    # Updating API access credentials
    user.access_token = current_facebook_user.access_token
    user.access_token_expire_at = current_facebook_user.access_token_expires_at
    
    # Updating visit info
    user.last_visit_at = Time.now if user.last_visit_at.nil? || user.last_visit_at < 30.minutes.ago
    user.last_visit_ip = request.remote_ip
    
    user.save! if user.changed?
    
    user
  end
  
  def find_or_create_offline_user
    User.find_or_create_by_facebook_id(1)
  end
  
  def check_user_ban
    if current_user and current_user.banned?
      render :text => "You're banned. The reason: #{ current_user.ban_reason }"
      
      return false
    end
  end

  def get_layout
    (current_character.nil? || current_character.new_record?) ? "unauthorized" : "application"
  end

  def store_return_to(uri = nil)
    session[:return_to] = uri
    session[:return_to] ||= params[:return_to]
    session[:return_to] ||= url_for(params_without_facebook_data.merge(:canvas => true)) unless controller_name == 'characters' && action_name == 'index'
  end

  def redirect_back(uri)
    if session[:return_to].present?
      uri = session[:return_to]

      session[:return_to] = nil
    end
    
    redirect_to uri
  end
  
  def check_standalone
    if from_canvas = params.delete(:from_canvas) and from_canvas == 'false'
      store_signed_request_in_session
      
      redirect_from_iframe url_for(
        params.merge(:host => facepalm.callback_domain)
      )
    end
    
    true
  end
  
  def store_signed_request_in_session
    session[fb_sighed_request_session] = fb_signed_request
  end
end
