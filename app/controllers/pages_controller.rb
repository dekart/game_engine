class PagesController < ApplicationController
  skip_before_filter :ensure_application_is_installed_by_facebook_user
  skip_before_filter :check_character_personalization

  def show
    @@references ||= %w{welcome_notification}

    render :action => params[:id], :layout => !@@references.include?(params[:id])
  end
end
