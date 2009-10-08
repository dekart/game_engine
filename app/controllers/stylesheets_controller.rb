class StylesheetsController < ApplicationController
  include StylesheetsHelper
  
  skip_before_filter :ensure_application_is_installed_by_facebook_user
  
  def show
    @stylesheet = Stylesheet.find_by_id(params[:id]) || params[:id]

    respond_to do |format|
      format.css do
        render :action => :show, :layout => false
      end
    end
  end

  def source
    @code = File.read(default_stylesheet_path)

    respond_to do |format|
      format.css do
        render :text => @code
      end
    end
  end
end
