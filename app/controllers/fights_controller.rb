class FightsController < ApplicationController
  def new
    @victims = Character.victims_for(current_character).scoped(
      :order => "RAND()",
      :limit => Setting.i(:fight_victim_show_limit)
    )

    @victims = @victims.not_friends_with(current_character) unless Setting.b(:fight_alliance_attack)
  end

  def create
    @victim = Character.find(params[:victim_id])

    @fight = Fight.create(
      :attacker => current_character,
      :victim   => @victim
    )

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

    render :action => :create, :layout => "ajax"
  end

  def used_items
    @fight = current_character.attacks.find(params[:id])

    render :action => :used_items, :layout => "ajax"
  end
end
