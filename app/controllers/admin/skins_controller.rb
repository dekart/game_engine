class Admin::SkinsController < Admin::BaseController
  DEFAULT_SKIN_PATH = Rails.root.join("public", "stylesheets", "sass", "_default_skin.sass")

  def index
    @skins = Skin.all
  end

  def new
    @skin = Skin.new
  end

  def create
    @skin = Skin.new(params[:skin])

    if @skin.save
      redirect_to admin_skins_path
    else
      render :action => :new
    end
  end

  def edit
    @skin = Skin.find(params[:id])
  end

  def update
    @skin = Skin.find(params[:id])

    if @skin.update_attributes(params[:skin])
      redirect_to admin_skins_path
    else
      render :action => :edit
    end
  end

  def activate
    @skin = Skin.find(params[:id])

    @skin.activate! unless @skin.active?

    redirect_to admin_skins_path
  end

  def destroy
    @skin = Skin.find(params[:id])

    @skin.destroy

    redirect_to admin_skins_path
  end

  def show
    @skin_content = File.read(DEFAULT_SKIN_PATH)
  end

  def changelog
    @changelog = %x{git log -p --since=#{params[:log]["since(1i)"]}-#{params[:log]["since(2i)"]}-#{params[:log]["since(3i)"]} #{DEFAULT_SKIN_PATH}}
  end
end
