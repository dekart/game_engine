class Admin::AssetsController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @assets = Asset.paginate(:order => :alias, :page => params[:page])
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
      redirect_to admin_assets_url(:canvas => true)
    else
      redirect_to new_admin_asset_url(:asset => params[:asset], :canvas => true)
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
      redirect_to admin_assets_url(:canvas => true)
    else
      redirect_to edit_admin_asset_url(:asset => params[:asset], :canvas => true)
    end
  end

  def destroy
    @asset = Asset.find(params[:id])

    @asset.destroy

    redirect_to :action => :index
  end
end
