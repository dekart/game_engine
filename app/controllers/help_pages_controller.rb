class HelpPagesController < ApplicationController
  skip_authentication_filters

  def show
    @page = HelpPage.find_by_alias(params[:id])

    render :layout => false if request.xhr?
  end
end
