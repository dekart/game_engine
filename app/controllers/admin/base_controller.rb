class Admin::BaseController < ApplicationController
  skip_before_filter :check_bookmark_reference

  before_filter :admin_required

  layout "admin/layouts/application"

  protected
  
  def ajax_layout
    "admin/layouts/ajax"
  end
end