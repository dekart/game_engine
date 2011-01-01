class WallPostsController < ApplicationController
  def create
    @character = Character.find(params[:character_id])

    @wall_post = @character.wall_posts.build(params[:wall_post])
    @wall_post.author = current_character

    if @wall_post.save
      @wall_posts = @character.wall_posts.paginate(:page => 1)
    end

    render :layout => 'ajax'
  end
end
