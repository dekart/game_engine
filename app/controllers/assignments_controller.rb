class AssignmentsController < ApplicationController
  def new
    @assignment = parents.last.assignments.build(:role => params[:role])
    
    render :action => :new, :layout => false
  end

  def create
    @assignment = parents.last.assignments.build(params[:assignment])

    if @assignment.save
      Delayed::Job.enqueue Jobs::AssignmentNotification.new(facebook_session, @assignment.id)
    end

    if @assignment.context.is_a?(Character)
      redirect_to relations_url
    elsif @assignment.context.is_a?(Property)
      redirect_to properties_url
    end
  end
end
