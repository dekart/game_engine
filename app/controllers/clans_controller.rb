class ClansController < ApplicationController
  before_filter :check_for_presence_of_clan, :only => [:new]
  before_filter :check_creator_for_clan, :only => [:edit]
  
  def index
    @clans = Clan.scoped(:order => "members_count DESC").paginate(:per_page => 50, :page => params[:page])
  end
  
  def show
    @clan = Clan.find(params[:id])
    @invitation = current_character.clan_membership_invitations.detect{|i| i.clan_id == @clan.id}
  end

  def new
    @clan = Clan.new
  end
  
  def create
    @clan = Clan.new(params[:clan])
    
    if @clan.create_by!(current_character)
      flash[:success] = t("clans.create.success")
      
      redirect_from_iframe(clan_path(@clan, :canvas => true))
    else      
      render :action => "new"
    end
  end

  def edit
    @clan = Clan.find(params[:id])
  end
  
  def update
    @clan = Clan.find(params[:id])
     
    if @clan.update_attributes(params[:clan])
      flash[:success] = t("clans.update.success")
      
      redirect_from_iframe(clan_path(@clan, :canvas => true))
    else
      render :action => "edit"
    end
  end
  
  def change_image
    @clan = Clan.find(params[:id])
    
    if @clan.change_image!(params[:clan])
      flash[:success] = t("clans.update_image.success")
      
      redirect_from_iframe(clan_path(@clan, :canvas => true))
    else
      render :action => "edit"
    end
  end
  
  private
  
  def check_for_presence_of_clan
    if current_character.clan
      redirect_from_iframe(clans_path(:canvas => true))
    end
  end
  
  def check_creator_for_clan
    unless current_character.clan_member.try(:creator?)
      redirect_from_iframe(clans_path(:canvas => true))
    end
  end
end
