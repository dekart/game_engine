class StoriesController < ApplicationController
  def show
    story_data = encryptor.decrypt(params[:story_data])
    
    if @story = Story.find_by_id(params[:id])
      payouts = @story.track_visit!(current_character, story_data)
      
      key = @story.alias
    else
      payouts = []
      key = params[:id]
    end
        
    @next_page = case key
    when 'inventory'
      items_url(:canvas => true)
    when 'mission', 'boss'
      mission_group_url(story_data[:mission_group_id], :canvas => true)
    else
      root_url(:canvas => true)
    end
    
    redirect_from_iframe(@next_page) if payouts.empty?
  end
end
