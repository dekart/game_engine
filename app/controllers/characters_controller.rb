class CharactersController < ApplicationController
  skip_before_filter :prepare_user_and_character, :only => :load_vip_money

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
      super_rewards_user.character.increment!(:vip_money, params[:new].to_i)

      render :text => "1"
    else
      render :text => "0"
    end
  end

  def current
    render :json => current_character
  end
end
