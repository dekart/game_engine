class Admin::CharactersController < Admin::BaseController
  def index
    @characters = Character.paginate(:page => params[:page])
  end

  def search
    if params[:profile_ids].present?
      ids = params[:profile_ids].split(/[^\d]+/)
      per_page = ids.size

      @characters = Character.scoped(:conditions => {:id => ids})
    elsif params[:facebook_ids].present?
      ids = params[:facebook_ids].split(/[^\d]+/)
      per_page = ids.size

      @characters = Character.scoped(
        :include => :user,
        :conditions => {:users => {:facebook_id => ids}}
      )
    else
      @characters = Character

      per_page = 100
    end

    @characters = @characters.paginate(:page => params[:page], :per_page => per_page)
    
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

  def payout
    @character = Character.find(params[:id])

    if request.put? and params[:character]
      @character.payouts = params[:character][:payouts]

      @character.save!

      redirect_to admin_characters_path
    end
  end
end
