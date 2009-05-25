class AssignmentsController < ApplicationController
  def new
    @assignment = parents.last.assignments.build(:role => params[:role])
    
    render :action => :new, :layout => false
  end

  def create
    @assignment = parents.last.assignments.create(params[:assignment])

    if @assignment.context.is_a?(Character)
      redirect_to relations_url
    elsif @assignment.context.is_a?(Property)
      redirect_to properties_url
    end
  end
end
