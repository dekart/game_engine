class Admin::CharactersController < Admin::BaseController
  skip_before_filter :admin_required, :only => [:stop_simulate]

  def index
    @characters = Character.paginate(:page => params[:page])
  end

  def show
    @character = Character.find(params[:id])
  end

  def search
    if params[:search][:profile_ids].present?
      @ids = params[:search][:profile_ids].split(/[^\d]+/)
    elsif params[:search][:signed_request].present?
      @ids = [Facepalm::User.from_signed_request(facepalm, params[:search][:signed_request]).uid]
    else
      @ids = []
    end

    if @ids.empty?
      @characters = Character
    else
      @characters = Character.by_profile_ids(@ids)
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

  def simulate
    if current_user.admin? && current_user.simulation.nil?
      Character.find(params[:id]).user.tap do |user|
        current_user.create_simulation(:user => user)

        flash[:success] = t(".success",
            :name => user.character.name.blank? ? user.first_name : user.character.name
          ).html_safe
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def stop_simulate
    if current_user.simulated? && @real_user && @real_user.admin?
      @real_user.simulation.destroy
    end

    redirect_to root_url
  end
end
