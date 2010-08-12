class Admin::BaseController < ApplicationController
  skip_before_filter :check_bookmark_reference

  before_filter :admin_required

  layout "admin/layouts/application"

  protected
  
  def ajax_layout
    "admin/layouts/ajax"
  end

  def unless_continue_editing(options = {}, &block)
    if params[:continue]
      render options.reverse_merge(:action => :edit)
    else
      yield
    end
  end
end