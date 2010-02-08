class Admin::BaseController < ApplicationController
  before_filter :admin_required

  layout "admin/layouts/application"

  protected
  
  def ajax_layout
    "admin/layouts/ajax"
  end
end