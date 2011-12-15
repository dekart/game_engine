class ClansController < ApplicationController
  def index
    @clans = Clan.scoped(:order => "members_count DESC").paginate(:per_page => 50, :page => params[:page])
  end
  
  def show
    @clan = Clan.find(params[:id])
    @clan_members = @clan.clan_members
  end

  def new
    @clan = Clan.new
  end
  
  def create
    @clan = Clan.new(params[:clan])
    
    if @result = @clan.create_by!(current_character)
      flash[:success] = t("create.success")
      
      redirect_from_iframe(clan_path(@clan, :canvas => true))
    else      
      render :action => "new"
    end
  end

  def edit
    @clan = Clan.find(params[:id])
    @clan_members = @clan.clan_members
  end
  
  def update
    @clan = Clan.find(params[:id])
    @clan_members = @clan.clan_members
     
    if @clan.update_attributes(params[:clan])
      flash[:success] = t("update.success")
      
      redirect_from_iframe(clan_path(@clan, :canvas => true))
    else
      render :action => "edit"
    end
  end
  
  def change_image
    @clan = Clan.find(params[:id])
    @clan_members = @clan.clan_members
    
    @result = @clan.change_image!(params[:clan])
    
    if @result
      flash[:success] = t("update_image.success")
      
      redirect_from_iframe(clan_path(@clan, :canvas => true))
    else
      render :action => "edit"
    end
  end
end
