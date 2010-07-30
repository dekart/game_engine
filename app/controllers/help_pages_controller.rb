class HelpPagesController < ApplicationController
  def show
    @page = HelpPage.find_by_alias(params[:id]) or raise ActiveRecord::RecordNotFound

    respond_to do |format|
      format.js { render :layout => false }
      format.html
    end
  end
end
