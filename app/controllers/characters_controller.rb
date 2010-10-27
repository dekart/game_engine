class CharactersController < ApplicationController
  skip_before_filter :check_character_existance,
    :only => [:new, :create]

  skip_landing_redirect :except => [:index, :upgrade]
  
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
    else
      render :action => :upgrade, :layout => "ajax"
    end
  end

  def show
    @character = Character.find(params[:id])

    @secured = (@character.key == params[:id])
  end

  def new
    if current_character
      redirect_from_iframe root_url(:canvas => true)
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
        redirect_back root_url(:canvas => true)
      else
        render :action => :new
      end
    end
  end

  def edit
    @character = current_character

    if flash[:premium_change_name]
      @allow_name = true
    else
      redirect_to root_path
    end
  end

  def update
    @character = current_character

    @character.attributes = params[:character]
    @character.character_type ||= CharacterType.find_by_id(params[:character][:character_type_id])

    if @character.save
      redirect_from_iframe root_url(:canvas => true)
    else
      render :action => :edit
    end
  end

  def hospital
    if request.post?
      @result = current_character.hospital!
    end

    render :layout => "ajax"
  end

  protected

  def fetch_character_types
    @character_types = CharacterType.with_state(:visible).all
  end

  def check_character_existance_or_create
    if current_character
      true
    elsif params[:character]
      create
    else
      check_character_existance
    end
  end
end
