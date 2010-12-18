# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionLogging
  include FacebookIntegration
  include LandingPage
  include ReferenceCode

  before_filter :check_character_existance, :except => [:facebook_oauth_connect]
  facebook_integration_filters
  
  landing_redirect

  layout :get_layout

  helper_method :current_user, :current_character, :current_skin, :reference_code

  helper :all

  protected

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
      @current_user ||= find_or_create_current_user
    end
  end

  def find_or_create_current_user
    facebook_id = current_facebook_user.id

    unless user = User.find_by_facebook_id(facebook_id)
      user = User.new

      user.facebook_id  = facebook_id

      if params[:reference_code].present? and reference = decrypt_reference_code(params[:reference_code])
        user.reference    = reference[0]
        user.referrer_id  = reference[1]
      elsif params[:reference]
        user.reference    = params[:reference]
        
        #FIXME Stop parsing referrer passed in unencrypted params
        user.referrer_id  = params[:referrer]
      end
    end

    # Updating access token
    user.access_token = current_facebook_user.client.access_token
    
    user.save!

    user
  end

  def default_url_options(options = {})
    options[:try_skin] = params[:try_skin] unless params[:try_skin].blank?
    options
  end

  def admin_required
    redirect_from_iframe root_url(:canvas => true) unless current_user.admin?
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
    session[:return_to] ||= url_for(params.except(:signed_request).merge(:canvas => false, :only_path => true))
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
