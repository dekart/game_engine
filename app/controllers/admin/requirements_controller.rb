class Admin::RequirementsController < ApplicationController
  before_filter :admin_required

  def new
    @container    = params[:container]
    @requirement  = Requirements::Base.by_name(params[:type]).new

    render :action => :new, :layout => "admin/ajax"
  end
end
