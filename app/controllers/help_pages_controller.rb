class HelpPagesController < ApplicationController
  skip_before_filter :check_character_existance, :ensure_canvas_connected_to_facebook

  def show
    @page = HelpPage.find_by_alias(params[:id])

    render :layout => false if request.xhr?
  end
end
