class ClanMembershipApplicationsController < ApplicationController
  before_filter :find_application, :only => [:approve, :reject]
  after_filter  :delete_clan_membership_application, :only => [:approve, :reject]
  
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
    
    @clan_member = @application.clan.clan_members.build(:character => @application.character, :role => :participant)
    
    if @clan_member.save
       @application.character.notifications.schedule(:accepted_application,
          :clan_id      => @application.clan.id
       )
      render :layout => "ajax"
    end
  end
  
  def reject
    render :layout => "ajax"
  end
  
  private
  
  def find_application
    @application = ClanMembershipApplication.find(params[:id])
  end
  
  def delete_clan_membership_application
    @application.destroy
  end
end
