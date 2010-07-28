class Admin::CharactersController < Admin::BaseController
  def index
    @characters = Character.paginate(:page => params[:page])
  end

  def edit
    @character = Character.find(params[:id])
  end

  def update
    @character = Character.find(params[:id])

    if @character.update_attributes(params[:character])
      redirect_to admin_characters_path(:page => params[:page])
    else
      render :edit
    end
  end
end
