class ClanMembershipApplicationsController < ApplicationController
  before_filter :find_application, :only => [:approve, :reject]
  
  def create
    @clan = Clan.find(params[:clan_id])
    
    @application = current_character.clan_membership_applications.create(:clan => @clan)
    
    render :layout => "ajax"
  end
  
  def approve
    @result = @application.approve!
    
    @clan = Clan.find(@application.clan_id)
    
    render :layout => "ajax"
  end
  
  def reject
    @application.reject_by_creator!
    
    render :layout => "ajax"
  end
  
  private
  
  def find_application
    if current_character.clan_member.try(:creator?)
      @application = current_character.clan.clan_membership_applications.find(params[:id]) 
    end
  end
end
