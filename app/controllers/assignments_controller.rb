class AssignmentsController < ApplicationController
  def new
    @assignment = current_character.assignments.build(:role => params[:role])
    @relations  = current_character.send(Setting.b(:assignment_mercenaries) ? :relations : :friend_relations).not_banned

    render :json => {
      :available => @relations.available.map{|r| r.as_json_for_assignment(@assignment) },
      :assigned => @relations.assigned.map{|r| r.as_json_for_assignment(@assignment) }
    }
  end

  def create
    @assignment = current_character.assignments.build(params[:assignment])

    @assignment.save

    render :json => {
      :content => render_to_string(:partial => 'relations/assignments')
    }
  end

  def destroy
    if params[:id] == 'all'
      current_character.assignments.clear
    else
      @assignment = current_character.assignments.find(params[:id])

      @assignment.destroy
    end
  end
end
