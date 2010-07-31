class Admin::CharactersController < Admin::BaseController
  def index
    @characters = Character.paginate(:page => params[:page])
  end

  def search
    if params[:profile_ids].present?
      ids = params[:profile_ids].split(/[^\d]+/)

      @characters = Character.scoped(:conditions => {:id => ids})
    elsif params[:facebook_ids].present?
      ids = params[:facebook_ids].split(/[^\d]+/)

      @characters = Character.scoped(
        :include => :user,
        :conditions => {:users => {:facebook_id => ids}}
      )
    else
      @characters = Character
    end

    @characters = @characters.paginate(:page => params[:page])
    
    render :index
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
