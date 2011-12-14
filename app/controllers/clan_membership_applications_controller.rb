class ClanMembershipApplicationsController < ApplicationController
  before_filter :find_application, :only => [:approve, :reject]
  
  def new
    @clan = Clan.find(params[:clan_id])
    
    @application = @clan.clan_membership_applications.build(:character => current_character)
    
    if @application.save
      render :layout => "ajax"
    end
  end
  
  def approve
    if @application.character.clan_member
      @application.character.clan_member.destroy    
    end
    
    @clan_member = @application.create_clan_member!
    
    if @clan_member
      @application.character.delete_all_applications
      
      @application.establish_notification(:accepted)
    end
    
    render :layout => "ajax"
  end
  
  def reject
    @application.destroy
    
    @application.establish_notification(:rejected)
    
    render :layout => "ajax"
  end
  
  private
  
  def find_application
    @application = ClanMembershipApplication.find(params[:id])
  end
end
