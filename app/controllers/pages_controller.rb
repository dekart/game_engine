class PagesController < ApplicationController
  before_filter :admin_required
  skip_before_filter :ensure_application_is_installed_by_facebook_user

  def show
    @@references ||= %w{welcome_notification}

    render :action => params[:id], :layout => !@@references.include?(params[:id])
  end
end
