# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionLogging if Rails.env.production?

  filter_parameter_logging do |key, value|
    if key == "fb_sig_friends"
      count = value.blank? ? 0 : value.count(",") + 1

      value.replace "[#{count} friends]"
    end
  end

  before_filter :set_p3p_header
  before_filter :ensure_authenticated_to_facebook
  before_filter :check_character_existance

  layout :get_layout

  helper_method :current_user, :current_character, :profile_user, :in_profile_tab?, :in_canvas?, :request_context, :current_skin

  helper :all

  protected

  # Send P3P privacy header to enable iframe cookies in IE
  def set_p3p_header
    headers["P3P"] = 'CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"'
  end

  def landing_url
    if current_user.try(:should_visit_gift_page?)
      new_gift_path
    elsif current_user.try(:should_visit_invite_page?)
      invite_users_path
    else
      root_path
    end
  end

  def check_character_existance
    set_facebook_session

    unless current_character
      store_return_to

      redirect_to new_character_path(:reference => params[:reference] || params[:ref])
    end
  end

  def current_character(force_reload = false)
    current_user.character(force_reload) if current_user
  end

  def after_facebook_login_url
    params_hash = params.to_hash
    params_hash.reject!{|key, value| key.starts_with?("fb_sig") or key.starts_with?("_fb_") }
    params_hash[:canvas] = true

    url_for(params_hash)
  end

  def current_user
    @current_user ||= find_or_create_current_user if facebook_session
  end

  def find_or_create_current_user
    facebook_id = in_page? ? facebook_params["page_id"] : facebook_session.user.id

    unless user = User.find_by_facebook_id(facebook_id)
      user = User.new

      user.facebook_id  = facebook_id
      user.reference    = params[:reference]
      
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

  def redirect_to_landing_page
    if request.request_uri.starts_with?("//")
      new_url = request.request_uri.gsub(/^\/+/, "/#{Facebooker.facebooker_config["canvas_page_name"]}/")
    else
      new_url = landing_url
    end

    redirect_to new_url
  end

  def log_exception_and_redirect(exception)
    log_error(exception)

    redirect_to_landing_page
  end

  def params_before_conversion
    @raw_params ||= request.env['ORIGINAL_PARAMS']
  end

  def default_url_options(options)
    returning result = {} do
      result[:try_skin] = params[:try_skin] if params[:try_skin].present?
    end
  end

  def admin_required
    redirect_to landing_url unless current_user.admin?
  end

  def friend?(user)
    facebook_params["friends"].include?(user.facebook_id.to_s)
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
    if session[:return_to].present?
      uri = session[:return_to]

      session[:return_to] = nil
    end

    redirect_to(uri.to_s)
  end
end
