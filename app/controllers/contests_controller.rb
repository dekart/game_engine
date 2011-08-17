class ContestsController < ApplicationController
  def show  
    @contest = Contest.find(params[:id])
    
    @current_group = @contest.group_for(current_character)
  end
end