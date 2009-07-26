# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :ensure_application_is_installed_by_facebook_user
  
  helper_method :current_user, :current_character, :profile_user, :in_profile_tab?, :in_canvas?, :request_context

  helper :all

  rescue_from ActionController::RoutingError, :with => :redirect_to_root

  protected

  def current_character(force_reload = false)
    current_user.character(force_reload)
  end

  def after_facebook_login_url
    request.path
  end

  def check_explicit_installation_requirement
    params[:do_install] ? prepare_user_and_character : true
  end

  def current_user
    return if facebook_session.nil?

    @current_user ||= User.find_or_create_by_facebook_id(
       in_page? ? facebook_params["page_id"] : facebook_session.user.id
    )
  end

  def request_context
    if request_comes_from_facebook? && !facebook_params["in_profile_tab"].blank?
      return :profile_tab
    elsif request_comes_from_facebook? && !facebook_params["in_canvas"].blank?
      return :canvas
    else
      return :else
    end
  end

  def in_profile_tab?
    request_context == :profile_tab
  end

  def in_canvas?
    request_context == :canvas
  end

  def in_page?
    request_comes_from_facebook? && facebook_params["page_id"] && facebook_params["is_admin"] && facebook_params["page_added"]
  end

  def profile_user
    return if !in_profile_tab?

    @profile_user ||= User.find_or_create_by_facebook_id(facebook_params["profile_user"])
  end

  def redirect_to_root
    redirect_to root_url
  end

  def default_url_options(options)
    returning result = {} do
      result[:fb_page_id] = current_user.facebook_id if in_page? && options[:canvas] != false
      
      result[:try_stylesheet] = params[:try_stylesheet] unless params[:try_stylesheet].blank?
    end
  end

  def admin_required
    redirect_to root_url and return false unless current_user.admin?
  end
end
