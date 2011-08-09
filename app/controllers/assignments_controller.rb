class AssignmentsController < ApplicationController
  def new
    @assignment = parents.last.assignments.build(:role => params[:role])
    @relations = current_character.send(Setting.b(:assignment_mercenaries) ? :relations : :friend_relations).not_banned

    render :new, :layout => "ajax"
  end

  def create
    @assignment = parents.last.assignments.build(params[:assignment])

    @assignment.save

    if @assignment.errors.empty?
      EventLoggingService.log_event(:assignment_created, @assignment)
    end

    render :layout => 'ajax'
  end

  def destroy
    if params[:id] == 'all'
      current_character.assignments.clear
    else
      @assignment = Assignment.find(params[:id])

      if @assignment.context == current_character or @assignment.context.character == current_character
        @assignment.destroy

        EventLoggingService.log_event(:assignment_destroyed, @assignment)
      end
    end

    render :layout => 'ajax'
  end
end
