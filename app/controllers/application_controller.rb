# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :check_character_existance
  before_filter :ensure_application_is_installed_by_facebook_user
  
  layout :get_layout

  helper_method :current_user, :current_character, :profile_user, :in_profile_tab?, :in_canvas?, :request_context

  helper :all

  rescue_from ActionController::RoutingError,
    :with => :redirect_to_root
  rescue_from ActiveRecord::RecordNotFound, ActionController::UnknownAction,
    :with => :log_exception_and_redirect_to_root

  protected

  def check_character_existance
    set_facebook_session

    redirect_to new_character_url unless current_character
  end

  def current_character(force_reload = false)
    current_user.character(force_reload) if current_user
  end

  def after_facebook_login_url
    request.path
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

  def redirect_to_root
    if request.path.starts_with?("//")
      new_url = request.path.gsub(/^\/+/, "/#{Facebooker.facebooker_config["canvas_page_name"]}/")
    else
      new_url = root_url
    end

    Rails.logger.fatal "Redirecting to #{new_url} from #{request.path}"

    redirect_to new_url
  end

  def log_exception_and_redirect_to_root(exception)
    Rails.logger.fatal(params.inspect)
    
    log_error(exception)

    redirect_to_root
  end

  def default_url_options(options)
    returning result = {:canvas => true} do
      result[:fb_page_id] = current_user.facebook_id if in_page? && options[:canvas] != false
      
      result[:try_stylesheet] = params[:try_stylesheet] unless params[:try_stylesheet].blank?
    end
  end

  def admin_required
    redirect_to root_url unless current_user.admin?
  end

  def friend?(user)
    facebook_params["friends"].include?(user.facebook_id.to_s)
  end

  def get_layout
    (current_character.nil? || current_character.new_record?) ? "unauthorized" : "application"
  end
end
