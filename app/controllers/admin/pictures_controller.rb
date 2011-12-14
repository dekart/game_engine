class Admin::PicturesController < Admin::BaseController
  def new
    @container = params[:container]
    
    if klass = @container.classify.constantize
      container = params[:id] ? klass.find(params[:id]) : klass.new
      
      @picture = container.pictures.build
    
      render :layout => :ajax_layout
    end
  end
end
