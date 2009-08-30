class AssignmentsController < ApplicationController
  def new
    @assignment = parents.last.assignments.build(:role => params[:role])
    
    render :action => :new, :layout => false
  end

  def create
    @assignment = parents.last.assignments.build(params[:assignment])

    if @assignment.save
      goal(:assignment_promote, @assignment.role, @assignment.relation.id)

      Delayed::Job.enqueue Jobs::AssignmentNotification.new(facebook_session, @assignment.id)
    end

    redirect_to_context(@assignment)
  end

  def destroy
    @assignment = Assignment.find(params[:id])

    if @assignment.context.owner == current_character
      @assignment.destroy

      goal(:assignment_demote, @assignment.role, @assignment.relation.id)
    end

    redirect_to_context(@assignment)
  end

  protected

  def redirect_to_context(assignment)
    if assignment.context.is_a?(Character)
      redirect_to relations_url
    elsif assignment.context.is_a?(Property)
      redirect_to properties_url
    end
  end
end
