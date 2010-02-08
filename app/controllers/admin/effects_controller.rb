class Admin::EffectsController < Admin::BaseController
  def new
    @container  = params[:container]
    @effect     = Effects::Base.by_name(params[:type]).new(nil)

    render :layout => :ajax_layout
  end
end
