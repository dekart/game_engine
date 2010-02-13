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
  
  before_filter :ensure_authenticated_to_facebook
  before_filter :check_character_existance

      def top_redirect_to(*args)
        if request_is_facebook_iframe?
          @redirect_url = url_for(*args)
          render :layout => false, :inline => <<-HTML
            <html><head>
              <script type="text/javascript">
                window.top.location.href = <%= raw @redirect_url.to_json -%>;
              </script>
              <noscript>
                <meta http-equiv="refresh" content="0;url=<%=h @redirect_url %>" />
                <meta http-equiv="window-target" content="_top" />
              </noscript>
            </head></html>
          HTML
        else
          redirect_to(*args)
        end
      end

      def after_facebook_login_url
        root_url(:canvas => true)
      end

  
  layout :get_layout

  helper_method :current_user, :current_character, :profile_user, :in_profile_tab?, :in_canvas?, :request_context

  helper :all

  protected

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
      redirect_to new_character_path(:reference => params[:reference] || params[:ref])
    end
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
    returning result = {:canvas => true} do
      params_before_conversion.each do |key, value|
        result[key] = value if key.starts_with?("fb_sig")
      end
      #result[:fb_page_id] = current_user.facebook_id if in_page? && options[:canvas] != false
      
      result[:try_stylesheet] = params[:try_stylesheet] unless params[:try_stylesheet].blank?
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
end
