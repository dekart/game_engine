class Admin::EffectsController < ApplicationController
  before_filter :admin_required

  def new
    @container  = params[:container]
    @effect     = Effects::Base.by_name(params[:type]).new(nil)

    render :action => :new, :layout => "admin/ajax"
  end
end
