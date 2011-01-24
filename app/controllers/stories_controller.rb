class StoriesController < ApplicationController
  def show
    if @story = Story.find_by_id(params[:id])
      payouts = @story.track_visit!(current_character)
      
      key = @story.alias
    else
      payouts = []
      key = params[:id]
    end
    
    @next_page = case key
    when 'inventory'
      items_url(:canvas => true)
    when 'mission'
    else
      root_url(:canvas => true)
    end
    
    redirect_from_iframe(@next_page) if payouts.empty?
  end
end
