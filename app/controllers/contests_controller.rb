class ContestsController < ApplicationController
  def show  
    @contest = Contest.find(params[:id])
    @leaders = @contest.leaders(:limit => Setting.i(:contests_leaders_show_limit))
  end
end