class AssignmentsController < ApplicationController
  def new
    @assignment = current_character.assignments.build(:role => params[:role])
    @relations  = current_character.send(Setting.b(:assignment_mercenaries) ? :relations : :friend_relations).not_banned

    render :new, :layout => "ajax"
  end

  def create
    @assignment = current_character.assignments.build(params[:assignment])

    @assignment.save

    render :layout => 'ajax'
  end

  def destroy
    if params[:id] == 'all'
      current_character.assignments.clear
    else
      @assignment = current_character.assignments.find(params[:id])

      @assignment.destroy
    end

    render :layout => 'ajax'
  end
end
