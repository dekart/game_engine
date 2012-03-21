class RatingsController < ApplicationController
  def show
    @current_field = params[:field] || Rating::FIELDS.first
    
    if request.xhr?
      render(
        :partial => "list",
        :locals => {:field => @current_field},
        :layout => false
      )
    end
  end
end
