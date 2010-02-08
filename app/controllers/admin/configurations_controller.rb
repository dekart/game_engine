class Admin::ConfigurationsController < Admin::BaseController
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
