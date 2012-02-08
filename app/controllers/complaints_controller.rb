class ComplaintsController < ApplicationController
  def new
    @complaint = current_character.complaints.build(:offender_id => params[:offender_id])
  end

  def create
    @complaint = current_character.complaints.create(params[:complaint])
  end
end
