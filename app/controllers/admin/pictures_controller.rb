class Admin::PicturesController < Admin::BaseController
  def new
    @container = params[:container]
    klass = @container.camelize.constantize
    
    container = params[:id] ? klass.find(params[:id]) : klass.new
    
    @picture = container.pictures.build
  end
end
