class FightsController < ApplicationController
  before_filter :check_fight_restrictions, :only => :new
  
  def index
    @victims = Fight.new(:attacker => current_character).opponents
    
    respond_to do |format|
      format.js
    end
  end
  
  def new
  end

  def create
    @victim = Character.find(params[:victim_id])

    @fight = Fight.create(
      :attacker => current_character,
      :victim   => @victim
    )
  end

  def respond
    @cause = current_character.defences.find(params[:id])
    @victim = @cause.attacker

    @fight = Fight.create(
      :attacker => current_character,
      :victim   => @victim,
      :cause    => @cause
    )

    render :action => :create
  end

  def used_items
    @fight = current_character.attacks.find(params[:id])

    @attacker_items = @fight.attacker_used_items
    @victim_items   = @fight.victim_used_items
  end

  protected
  
  def check_fight_restrictions
    if current_character.restrict_fighting?
      render 'characters/restrictions', :locals => { :restriction_type => :fighting }
    end
  end
end
