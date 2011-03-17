class FightsController < ApplicationController
  def new
    @victims = Fight.opponents(current_character).victims
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

    @attacker_items = @fight.attacker.used_items
    @victim_items   = @fight.victim.used_items

    render :action => :used_items, :layout => "ajax"
  end

end
