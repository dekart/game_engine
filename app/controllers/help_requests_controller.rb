class HelpRequestsController < ApplicationController
  def create
    if current_character.help_requests.can_publish?(params[:context_type])
      @context = params[:context_type].classify.constantize.find(params[:context_id])
      
      @help_request = current_character.help_requests.create!(:context => @context)

      goal(:help_request, @context.class.to_s, @context.id)
    end

    render :text => ""
  end

  def show
    @character = Character.find(params[:id])

    if friend?(@character.user)
      @help_request = @character.help_requests.latest(params[:context])
      @help_result  = @help_request.help_results.create(:character => current_character)

      if @help_result.new_record?
        @fight = @help_result.fight if @help_request.context.is_a?(Fight)
        
        goal(:help_response, @help_request.context.class.to_s, @help_request.context.id)
      end
    end
  end
end
