class AppRequestsController < ApplicationController
  skip_before_filter :check_character_existance, :ensure_canvas_connected_to_facebook
  
  def create
    @requests = Array.wrap(params[:ids])
    
    @requests.each do |request_id|
      AppRequest.create(:facebook_id => request_id.to_i)
    end
    
    @request_type = params[:type]
    
    case @request_type
    when 'gift'
      @item = Item.find(params[:item_id])
    end

    render :layout => 'ajax'
  end
end
