class FightsController < ApplicationController
  def new
    @victims = Character.victims_for(current_character).find(:all, :order => "RAND()", :limit => 10)

    # Insert random non-registered friends
    (@victims.size / 3 + 1).times do |i|
      random_id = facebook_params["friends"][rand(facebook_params["friends"].size)]

      @victims.insert(i * @victims.size / 3, random_id) unless User.find_by_facebook_id(random_id)
    end
  end

  def create
    @victim = Character.find(params[:victim_id])

    if @fight = Fight.create(:attacker => current_character, :victim => @victim) and @fight.attacker_won?
      Delayed::Job.enqueue Jobs::FightNotification.new(facebook_session, @fight.id)
    end

    render :action => :create, :layout => "ajax"
  end

  def invite
    @victim = params[:victim_id]

    if @fight = FightWithInvite.create(:attacker => current_character, :victim => @victim)
      Delayed::Job.enqueue Jobs::FightInviteNotification.new(facebook_session, @victim)
    end

    render :action => :invite, :layout => "ajax"
  end
end
