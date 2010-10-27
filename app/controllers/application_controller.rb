# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Facebooker2::Rails::Controller
  
  include ExceptionLogging if Rails.env.production?
  include LandingPage

  rescue_from Facebooker2::OAuthException do |exception|
    redirect_to 'http://www.facebook.com/'
  end

  before_filter :ensure_canvas_connected_to_facebook
  before_filter :set_p3p_header
  before_filter :check_character_existance, :except => [:facebook_oauth_connect]

  landing_redirect

  layout :get_layout

  helper_method :current_user, :current_character, :current_skin

  helper :all

  protected

  def ensure_canvas_connected_to_facebook
    ensure_canvas_connected(:publish_stream, :email)
  end
  
  # Send P3P privacy header to enable iframe cookies in IE
  def set_p3p_header
    headers["P3P"] = 'CP="CAO PSA OUR"'
  end

  def check_character_existance
    unless current_character
      store_return_to

      url_params = params.to_hash.symbolize_keys
      url_params.merge!(
        :controller => "/characters",
        :action     => :new,
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
      unless @current_user
        @current_user = find_or_create_current_user

        @current_user.update_permissions!(facebook_params["ext_perms"]) unless facebook_params["ext_perms"].blank?
      end

      @current_user
    end
  end

  def find_or_create_current_user
    facebook_id = current_facebook_user.id

    unless user = User.find_by_facebook_id(facebook_id)
      user = User.new

      user.facebook_id  = facebook_id
      
      user.reference    = params[:reference]
      user.referrer_id  = params[:referrer]
      
      user.save!
    end

    user
  end

  def default_url_options(options = {})
    {}.tap do |result|
      result[:try_skin] = params[:try_skin] unless params[:try_skin].blank?
    end
  end

  def admin_required
    redirect_to root_path unless current_user.admin?
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
    session[:return_to] ||= request.request_uri
  end

  def redirect_back(uri)
    unless session[:return_to].blank?
      uri = session[:return_to]

      session[:return_to] = nil

      uri = 'http://apps.facebook.com/%s%s' % [
        Facebooker2.canvas_page_name,
        uri
      ]
    end

    redirect_from_iframe uri
  end
end
