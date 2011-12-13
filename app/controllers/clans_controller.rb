class ClansController < ApplicationController
  def index
    @clans = Clan.all(:order => "members_count DESC").paginate(:per_page => 50, :page => params[:page], :order => "members_count DESC")
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
    
    @result = @clan.create_by!(current_character)
    
    if @result
      flash[:success] = t("create.success")
      
      redirect_to clan_path(@clan)
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
      
      redirect_to clan_path(@clan)
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
      
      redirect_to clan_path(@clan)
    else
      render :action => "edit"
    end
  end
  
  def delete_member
    @target = ClanMember.find(params[:id])
    @clan   = @target.clan
    
    @target.destroy
    
    @clan_members = @clan.clan_members
    
    render :layout => "ajax"
  end

end
