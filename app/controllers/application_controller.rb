# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :check_character_existance
  before_filter :ensure_application_is_installed_by_facebook_user
  
  layout :get_layout

  helper_method :current_user, :current_character, :profile_user, :in_profile_tab?, :in_canvas?, :request_context

  helper :all

  rescue_from ActionController::RoutingError,
    :with => :redirect_to_landing_page
  rescue_from ActiveRecord::RecordNotFound, ActionController::UnknownAction,
    :with => :log_exception_and_redirect

  protected

  def landing_path
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

    redirect_to new_character_url unless current_character
  end

  def current_character(force_reload = false)
    current_user.character(force_reload) if current_user
  end

  def after_facebook_login_url
    request.request_uri
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
      new_url = landing_path
    end

    Rails.logger.fatal params.inspect
    Rails.logger.fatal "Redirecting from #{request.method.to_s.upcase} #{request.request_uri} to #{new_url}"

    redirect_to new_url
  end

  def log_exception_and_redirect(exception)
    log_error(exception)

    redirect_to_landing_page
  end

  def default_url_options(options)
    returning result = {:canvas => true} do
      result[:fb_page_id] = current_user.facebook_id if in_page? && options[:canvas] != false
      
      result[:try_stylesheet] = params[:try_stylesheet] unless params[:try_stylesheet].blank?
    end
  end

  def admin_required
    redirect_to landing_path unless current_user.admin?
  end

  def friend?(user)
    facebook_params["friends"].include?(user.facebook_id.to_s)
  end

  def get_layout
    (current_character.nil? || current_character.new_record?) ? "unauthorized" : "application"
  end
end
