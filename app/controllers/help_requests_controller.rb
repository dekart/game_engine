class HelpRequestsController < ApplicationController
  def create
    if current_character.help_requests.can_publish?
      current_character.help_requests.create!(:mission_id => params[:mission_id])
    end

    render :text => ""
  end

  def show
    @character = Character.find(params[:id])

    if friend?(@character.user)
      @help_request = @character.help_requests.latest
      @help_result  = @help_request.help_results.create(:character => current_character)
    end
  end
end
