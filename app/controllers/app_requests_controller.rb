class AppRequestsController < ApplicationController
  skip_before_filter :check_character_existance, :ensure_canvas_connected_to_facebook
  
  def create
    params[:request_ids].each do |request_id|
      AppRequest.create(:facebook_id => request_id.to_i)
    end
    
    render :text => ''
  end
end
