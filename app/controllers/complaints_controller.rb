class ComplaintsController < ApplicationController
  def new
    @complaint = current_character.complaints.build(:offender_id => params[:offender_id])
    
    render :layout => "ajax"
  end

  def create
    @complaint = current_character.complaints.create(params[:complaint])
    
    render :layout => "ajax"
  end

end
