class CharactersController < ApplicationController
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :only => :load_vip_money

  def index
    @latest_fights = Fight.with_participant(current_character).find(:all, :limit => 10)
    @alliance_invitations = Invitation.for_user(current_user).find(:all)
  end

  def upgrade
    if request.post?
      @success = current_character.upgrade_attribute!(params[:attribute])
      
      render :action => :upgrade_result, :layout => "ajax"
    else
      redirect_to character_path if current_character.points == 0
    end
  end

  def show
    @character = Character.find(params[:id])
  end

  def load_vip_money
    if valid_super_rewards_request?
      @character = super_rewards_user.character
      @character.vip_money += params[:new].to_i
      @character.save

      render :text => "1"
    else
      render :text => "0"
    end
  end

  def rating
    @characters = Character.find(:all, :order => "rating DESC", :limit => 20)
  end

  def bank
    if request.post?
      if current_character.bank_operation(params[:operation])
        flash[:success] = ""
      end
    end
  end

  def buy_money
    if request.post?
      case params[:exchange]
      when "money"
        current_character.exchange_money!
      end
    end
  end
end
