# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Facebooker2::Rails::Controller
  include Facebooker2::Rails::Controller::CanvasOAuth
  include Facebooker2::Rails::Controller::UrlRewriting
  
  include ExceptionLogging if Rails.env.production?
  include LandingPage

  ensure_canvas_connected_to_facebook 'publish_stream'

  rescue_from Facebooker2::OAuthException do |exception|
    redirect_to 'http://www.facebook.com/'
  end

  before_filter :set_p3p_header
  before_filter :check_character_existance
  before_filter :check_bookmark_reference

  landing_redirect

  layout :get_layout

  helper_method :current_user, :current_character, :profile_user, :in_profile_tab?, :in_canvas?, :request_context, :current_skin

  helper :all

  protected
  
  # Send P3P privacy header to enable iframe cookies in IE
  def set_p3p_header
    headers["P3P"] = 'CP="CAO PSA OUR"'
  end

  def check_character_existance
    unless current_character
      store_return_to

      url_params = original_params.to_hash.symbolize_keys
      url_params.merge!(
        :controller => "/characters",
        :action     => :new,
        :canvas     => true
      )

      redirect_from_iframe url_for(url_params)
    end
  end

  def check_bookmark_reference
    if params[:ref] == "bookmarks" and !request_is_facebook_iframe?
      redirect_to after_facebook_login_url
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

  def after_facebook_login_url
    params_hash = params.to_hash
    params_hash.reject!{|key, value| key.starts_with?("fb_sig") or key.starts_with?("_fb_") }
    params_hash[:canvas] = true

    url_for(params_hash)
  end

  def current_user
    if current_facebook_user
      logger.debug current_facebook_user.inspect

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

  def request_context
    if request_comes_from_facebook? && !facebook_params["in_profile_tab"].blank?
      :profile_tab
    elsif request_comes_from_facebook? && !facebook_params["in_canvas"].blank?
      :canvas
    else
      :else
    end
  end

  def in_profile_tab?
    request_context == :profile_tab
  end

  def in_canvas?
    request_context == :canvas
  end

  def in_page?
    request_comes_from_facebook? &&
      facebook_params["page_id"] &&
      facebook_params["is_admin"] &&
      facebook_params["page_added"]
  end

  def profile_user
    if in_profile_tab?
      @profile_user ||= User.find_or_create_by_facebook_id(facebook_params["profile_user"])
    end
  end

  def original_params
    request.env['ORIGINAL_PARAMS'] || params
  end

  def default_url_options(options = {})
    {}.tap do |result|
      result[:try_skin] = params[:try_skin] unless params[:try_skin].blank?
    end
  end


  def with_canvas_relative_root
    @relative_root = Facebooker2.canvas_page_name
    yield
    @relative_root = nil
  end

  def relative_url_root
    Facebooker2.canvas_page_name#@relative_root
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
    end

    redirect_to(uri.to_s)
  end
end
