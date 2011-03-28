class AssignmentsController < ApplicationController
  def new
    @assignment = parents.last.assignments.build(:role => params[:role])
    @relations = Setting.b(:assignment_mercenaries) ? current_character.relations : current_character.friend_relations

    render :new, :layout => "ajax"
  end

  def create
    @assignment = parents.last.assignments.build(params[:assignment])

    @assignment.save

    if @assignment.errors.empty?
      EventLoggingService.log_event(assignment_event_data(:assignment_created, @assignment))
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

        EventLoggingService.log_event(assignment_event_data(:assignment_destroyed, @assignment))
      end
    end

    render :layout => 'ajax'
  end

  protected

  def assignment_event_data(event_type, assignment)
    {
      :event_type => event_type,
      :character_id => assignment.relation.owner.id,
      :level => assignment.relation.owner.level,
      :reference_id => assignment.relation.character.id,
      :reference_type => "Character",
      :reference_level => assignment.relation.character.level,
      :string_value => assignment.role,
      :occurred_at => Time.now
    }.to_json
  end
end
