class Admin::AssetsController < Admin::BaseController
  def index
    @assets = Asset.paginate(:order => :alias, :page => params[:page], :per_page => 100)
  end

  def new
    @asset = Asset.new

    if params[:asset]
      @asset.attributes = params[:asset]

      @asset.valid?
    end
  end

  def create
    @asset = Asset.new(params[:asset])

    if @asset.save
      redirect_to admin_assets_path
    else
      render :action => :new
    end
  end

  def edit
    @asset = Asset.find(params[:id])

    if params[:asset]
      @asset.attributes = params[:asset]

      @asset.valid?
    end
  end

  def update
    @asset = Asset.find(params[:id])

    if @asset.update_attributes(params[:asset])
      redirect_to admin_assets_path
    else
      render :action => :edit
    end
  end

  def destroy
    @asset = Asset.find(params[:id])

    @asset.destroy

    redirect_to admin_assets_path
  end
end
