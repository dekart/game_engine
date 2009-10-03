class Admin::ConfigurationsController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def edit
    @configuration = Configuration.find(params[:id])
  end

  def update
    @configuration = Configuration.current

    if @configuration.update_attributes(params[:configuration])
      redirect_to edit_admin_configuration_path(@configuration)
    else
      render :action => :edit
    end
  end
end
