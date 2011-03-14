class AssignmentsController < ApplicationController
  def new
    @assignment = parents.last.assignments.build(:role => params[:role])
    @relations = Setting.b(:assignment_mercenaries) ? current_character.relations : current_character.friend_relations

    render :new, :layout => "ajax"
  end

  def create
    @assignment = parents.last.assignments.build(params[:assignment])

    @assignment.save

    if @assignment.errors.empty
      EventLoggingService.log_event(:assignment_created, assignment_event_data(@assignment))
    end

    redirect_to_context(@assignment)
  end

  def destroy
    if params[:id] == 'all'
      current_character.assignments.clear
    else
      @assignment = Assignment.find(params[:id])

      if @assignment.context == current_character or @assignment.context.character == current_character
        @assignment.destroy

        EventLoggingService.log_event(:assignment_destroyed, assignment_event_data(@assignment))
      end
    end

    render :layout => 'ajax'
  end

  protected

  def redirect_to_context(assignment)
    if assignment.context.is_a?(Character)
      redirect_from_iframe relations_url(:canvas => true)
    elsif assignment.context.is_a?(Property)
      redirect_from_iframe properties_url(:canvas => true)
    end
  end

  def assignment_event_data(assignment)
    {
      :character_id => assignment.relation.owner.id,
      :character_level => assignment.relation.owner.level,
      :target_id => assignment.relation.character.id,
      :target_level => assignment.relation.character.level,
      :role => assignment.role
    }.to_json
  end
end
