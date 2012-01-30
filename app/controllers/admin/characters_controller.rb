class Admin::CharactersController < Admin::BaseController
  def index
    @characters = Character.paginate(:page => params[:page])
  end

  def show
    @character = Character.find(params[:id])
  end

  def search
    if params[:profile_ids].present?
      @ids = params[:profile_ids].split(/[^\d]+/)

      @characters = Character.by_profile_ids(@ids)
    else
      @characters = Character
    end

    @characters = @characters.paginate(
      :page     => params[:page],
      :per_page => @ids.try(:size) || 100
    )

    render :index
  end

  def edit
    @character = Character.find(params[:id])
  end

  def update
    @character = Character.find(params[:id])

    if @character.update_attributes(params[:character])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_characters_path
      end
    else
      render :edit
    end
  end

  def payout
    @characters = Character.find(Array.wrap(params[:ids]))

    if request.put? and params[:character]
      Character.transaction do
        payouts = Payouts::Collection.parse(params[:character][:payouts])

        @characters.each do |character|
          payouts.apply(character, :save, :admin_payout)

          character.save!
        end
      end

      flash[:success] = t(".success")

      unless_continue_editing :action => :payout do
        redirect_to admin_characters_path
      end
    end
  end
end
