class ContestsController < ApplicationController
  def show  
    @contest = Contest.find(params[:id])
    @leaders_with_points = @contest.leaders_with_points(:limit => Setting.i(:contests_leaders_show_limit))
  end
end