class HelpRequestsController < ApplicationController
  def create
    if current_character.help_requests.can_publish?(params[:context_type])
      @context = params[:context_type].classify.constantize.find(params[:context_id])
      
      @help_request = current_character.help_requests.create!(:context => @context)
    end

    render :text => ""
  end

  def show
    @character = Character.find(params[:id])

    if friend?(@character.user)
      @help_request = @character.help_requests.latest(params[:context])

      @help_result  = @help_request.help_results.create(:character => current_character)

      @fight = @help_result.fight if @help_request.context.is_a?(Fight) and !@help_result.new_record?
    end
  end
end
