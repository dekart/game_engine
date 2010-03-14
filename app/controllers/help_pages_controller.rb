class HelpPagesController < ApplicationController
  def show
    if @page = HelpPage.find_by_alias(params[:id])
      render :layout => false
    else
      render :text => ""
    end
  end
end
