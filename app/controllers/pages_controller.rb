class PagesController < ApplicationController
  before_filter :admin_required, :only => [:statistics]
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :except => [:statistics]

  caches_page :stylesheet
  
  def show
    @@references ||= [] # Reference names

    render :action => params[:id], :layout => !@@references.include?(params[:id])
  end

  def stylesheet
    respond_to do |format|
      format.css do
        render :template => "pages/stylesheets/#{params[:id]}", :layout => false
      end
    end
  end

  def statistics
  end
end
