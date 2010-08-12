class Admin::SettingsController < Admin::BaseController
  def index
    @settings = Setting.all(:order => :alias)
  end

  def new
    @setting = Setting.new
  end

  def create
    @setting = Setting.new(params[:setting])

    if @setting.save
      unless_continue_editing do
        redirect_to admin_settings_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @setting = Setting.find(params[:id])
  end

  def update
    @setting = Setting.find(params[:id])

    if @setting.update_attributes(params[:setting])
      unless_continue_editing do
        redirect_to admin_settings_path
      end
    else
      render :action => :edit
    end
  end

  def destroy
    @setting = Setting.find(params[:id])

    @setting.destroy

    redirect_to admin_settings_path
  end
end
