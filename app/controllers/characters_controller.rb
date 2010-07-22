class CharactersController < ApplicationController
  skip_before_filter :check_character_existance,
    :only => [:new, :create, :load_vip_money]
  skip_before_filter :ensure_authenticated_to_facebook,
    :only => [:load_vip_money, :new]

  skip_landing_redirect :except => [:index, :upgrade]
  
  before_filter :set_facebook_session,
    :only => [:new]
  before_filter :fetch_character_types,
    :only => [:new, :create, :edit, :update]

  def index
    @latest_fights = Fight.with_participant(current_character).find(:all,
      :limit => Setting.i(:fight_latest_show_limit)
    )

    @alliance_invitations = Invitation.for_user(current_user).find(:all)

    @special_items = Item.with_state(:visible).available.available_in(:special).available_for(current_character).all(
      :limit => 2,
      :order => "RAND()"
    )
  end

  def upgrade
    if request.post?
      @success = current_character.upgrade_attribute!(params[:attribute])

      render :action => :upgrade_result, :layout => "ajax"
    end
  end

  def show
    @character = Character.find(params[:id])
  end

  def load_vip_money
    on_valid_facebook_money_request do
      @character = facebook_money_user.character
      @character.vip_money += facebook_money_amount
      @character.save
    end
  end

  def bank
    if request.post?
      if current_character.bank_operation(params[:operation])
        flash[:success] = ""
      end
    end
  end

  def new
    if current_character
      redirect_to root_path
    else
      @character = Character.new
      @character.name ||= Setting.s(:character_default_name)
      @character.character_type ||= @character_types.first
    end
  end

  def create
    if current_character
      update
    else
      @character = current_user.build_character(params[:character])

      @character.character_type ||= CharacterType.find_by_id(params[:character][:character_type_id])

      if @character.save
        redirect_back root_path
      else
        render :action => :new
      end
    end
  end

  def edit
    @character = current_character

    @character.personalize_from(facebook_session)
  end

  def update
    @character = current_character

    @character.attributes = params[:character]
    @character.character_type ||= CharacterType.find_by_id(params[:character][:character_type_id])

    if @character.save
      redirect_to root_path
    else
      render :action => :edit
    end
  end

  protected

  def fetch_character_types
    @character_types = CharacterType.with_state(:visible).all
  end
end
