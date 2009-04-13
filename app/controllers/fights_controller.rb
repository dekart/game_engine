class FightsController < ApplicationController
  def new
    @victims = Character.victims_for(current_character).find(:all, :order => "RAND()", :limit => 10)
  end

  def create
    @victim = Character.find(params[:victim_id])

    if @fight = current_character.attacks.create(:victim => @victim)
      Delayed::Job.enqueue Jobs::FightNotification.new(facebook_session, @fight.id)
    end

    render :action => :create, :layout => "ajax"
  end
end
