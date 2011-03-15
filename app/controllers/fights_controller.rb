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

    EventLoggingService.log_event(fight_event_data(:character_fight, @fight))

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

  def fight_event_data(event_type, fight)
    {
      :event_type => event_type,
      :character_id => fight.attacker.id,
      :level => fight.attacker.level,
      :reference_id => fight.victim.id,
      :reference_type => "Character",
      :reference_level => fight.victim.level,
      :attacker_damage => fight.attacker_damage,
      :victim_damage => fight.victim_damage,
      :basic_money => fight.attacker_won? ? fight.winner_money : fight.loser_money,
      :victim_money => fight.attacker_won? ? fight.loser_money : fight.winner_money,
      :experience => fight.experience,
      :occurred_at => Time.now
    }.to_json
  end
end
