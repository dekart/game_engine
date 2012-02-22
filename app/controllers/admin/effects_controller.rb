class Admin::EffectsController < Admin::BaseController
  def new
    @container = params[:container]
    @effect = Effects::Base.by_name(params[:type]).new
  end
end
