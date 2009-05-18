class PagesController < ApplicationController
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
