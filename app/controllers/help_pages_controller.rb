class HelpPagesController < ApplicationController
  def show
    @page = HelpPage.find_by_alias(params[:id]) or raise ActiveRecord::RecordNotFound

    respond_to do |format|
      format.js { render :layout => false }
      format.html { render :layout => "unauthorized"}
    end
  end
end
