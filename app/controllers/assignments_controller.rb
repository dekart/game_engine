class AssignmentsController < ApplicationController
  def new
    @assignment = parents.last.assignments.build(:role => params[:role])
    
    render :action => :new, :layout => "ajax"
  end

  def create
    @assignment = parents.last.assignments.build(params[:assignment])

    @assignment.save

    redirect_to_context(@assignment)
  end

  def destroy
    if params[:id] == 'all'
      current_character.assignments.clear
      redirect_to relations_url
    else
      @assignment = Assignment.find(params[:id])

      if @assignment.context.owner == current_character
        @assignment.destroy
      end

      redirect_to_context(@assignment)
    end
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
