class CharactersController < ApplicationController
  def index
  end

  def upgrade
    if request.post?
      @success = current_character.upgrade_attribute!(params[:attribute])
      
      render :action => :upgrade_result, :layout => false
    else
      redirect_to character_path if current_character.points == 0
    end
  end

  def show
    @character = Character.find(params[:id])

    if @character == current_character and !params[:public]
      render :action => :show_private
    else
      render :action => :show_public
    end
  end
end
