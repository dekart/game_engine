class NewsfeedsController < ApplicationController
  def show
    @character = if params[:id]
      Character.find(params[:id])
    else
      current_character
    end

    @newsfeed = @character.news.last(10)

    render :layout => false
  end
end
