class HelpRequestsController < ApplicationController
  skip_landing_redirect

  def create
    if current_character.help_requests.can_publish?(params[:context_type])
      @context = params[:context_type].classify.constantize.find(params[:context_id])

      @help_request = current_character.help_requests.create!(:context => @context)
    end

    render :text => ""
  end

  # FIXME This should work even if user haven't installed the application yet. Visited url should
  # be stored to session, user signs up and see an option to go back and help his friend
  def show
    @character = Character.find_by_id(params[:id])

    if @character and @help_request = @character.help_requests.latest(params[:context])
      @help_result  = @help_request.help_results.create(:character => current_character)

      if !@help_result.new_record? and @help_request.context.is_a?(Fight)
        @fight = @help_result.fight
      end
    else
      redirect_to root_path
    end
  end
end
