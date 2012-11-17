class ContestsController < ApplicationController
  def show
    @contest = Contest.find(params[:id])

    @current_group = @contest.group_for(current_character)
  end

  def collect_reward
    @contest = Contest.find(params[:id])

    @group = @contest.group_for(current_character)

    if @group.rewardable?(current_character)
      @reward = @group.apply_reward!(current_character)
    end
  end
end