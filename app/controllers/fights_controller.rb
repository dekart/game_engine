class FightsController < ApplicationController
  def new
    @victims = current_character.possible_victims
  end

  def create
    @victim = Character.find(params[:victim_id])

    @fight = Fight.create(
      :attacker => current_character,
      :victim   => @victim
    )

    EventLoggingService.log_event(:character_fight, fight_event_data(@fight))

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

  protected

  def fight_event_data(fight)
    {
      :character_id => fight.attacker.id,
      :character_level => fight.attacker.level,
      :victim_id => fight.victim.id,
      :victim_level => fight.victim.level,
      :won => fight.attacker_won?,
      :is_responce => fight.is_response?,
      :attacker_damage => fight.attacker_damage,
      :victim_damage => fight.victim_damage,
      :winner_money => fight.winner_money,
      :loser_money => fight.loser_money,
      :experience => fight.experience
    }.to_json
  end
end
