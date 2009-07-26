class StylesheetsController < ApplicationController
  skip_before_filter :ensure_application_is_installed_by_facebook_user
  
  def show
    @stylesheet = Stylesheet.find_by_id(params[:id]) || params[:id]

    respond_to do |format|
      format.css do
        render :action => :show, :layout => false
      end
    end
  end
end
