class FightsController < ApplicationController
  def new
    @victims = Character.victims_for(current_character).find(:all,
      :order => "RAND()",
      :limit => Configuration[:fight_victim_show_limit]
    )

    # FIXME Friend list should be gathered separately by AJAX request or background API request
    # Insert random non-registered friends
#    if current_character.allow_fight_with_invite? and facebook_params["friends"].any?
#      (@victims.size / 3 + 1).times do |i|
#        random_id = facebook_params["friends"][rand(facebook_params["friends"].size)]
#
#        @victims.insert(i * @victims.size / 3, random_id) unless User.find_by_facebook_id(random_id)
#      end
#    end
  end

  def create
    @victim = Character.find(params[:victim_id])

    @fight = Fight.create(
      :attacker => current_character,
      :victim   => @victim
    )

    if !@fight.new_record? and @fight.attacker_won?
      Delayed::Job.enqueue Jobs::FightNotification.new(facebook_session, @fight.id)
    end

    render :action => :create, :layout => "ajax"
  end

  def respond
    @cause = current_character.defences.find(params[:id])
    @victim = @cause.attacker

    @fight = Fight.create(
      :attacker => current_character,
      :victim   => @victim,
      :cause    => @cause
    )

    if !@fight.new_record? and @fight.attacker_won?
      Delayed::Job.enqueue Jobs::FightNotification.new(facebook_session, @fight.id)
    end

    render :action => :create, :layout => "ajax"
  end

  def invite
    @victim = params[:victim_id]

    @fight = FightWithInvite.create(:attacker => current_character, :victim => @victim)

    Delayed::Job.enqueue Jobs::FightInviteNotification.new(facebook_session, @victim)

    render :action => :invite, :layout => "ajax"
  end

  def used_items
    @fight = current_character.attacks.find(params[:id])

    render :action => :used_items, :layout => "ajax"
  end
end
