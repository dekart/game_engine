class CharactersController < ApplicationController
  skip_before_filter :check_character_personalization, :only => [:new, :create, :edit, :update, :load_vip_money]
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :only => [:new, :load_vip_money]
  before_filter :set_facebook_session, :only => [:new]

  def index
    if !current_user.skip_tutorial?
      redirect_to tutorial_path
    elsif current_user.should_visit_gift_page?
      redirect_to new_gift_path
    elsif current_user.should_visit_invite_page?
      redirect_to invite_users_path
    else
      @latest_fights = Fight.with_participant(current_character).find(:all, 
        :limit => Configuration[:fight_latest_show_limit]
      )
      @alliance_invitations = Invitation.for_user(current_user).find(:all)
    end
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

  def rating
    @total       = Character.rated_by(:rating)
    @level       = Character.rated_by(:level)
    @bank        = Character.rated_by(:bank)
    @fights      = Character.rated_by(:fights_won)
    @missions    = Character.rated_by(:missions_succeeded)
    @relations   = Character.rated_by(:relations_count)
  end

  def bank
    if request.post?
      if current_character.bank_operation(params[:operation])
        flash[:success] = ""
      end
    end
  end

  def wall
    @character = Character.find(params[:id])
    
    render :action => :wall, :layout => false
  end

  def new
    redirect_to root_url if current_character

    @character = Character.new
  end

  def create
    @character = current_user.build_character(params[:character])

    if @character.save
      redirect_to root_path
    else
      render :action => :new
    end
  end

  def edit
    @character = current_character

    @character.personalize_from(facebook_session)
  end

  def update
    @character = current_character

    if @character.update_attributes(params[:character])
      redirect_to root_path
    else
      render :action => :edit
    end
  end
end
