class MonstersController < ApplicationController
  def index
    @defeated_monster_fights = current_character.monster_fights.defeated
    @active_monster_fights   = current_character.monster_fights.active
    
    @locked_monster = current_character.monster_types.available_in_future.first
    @monster_types  = current_character.monster_types.available_for_fight
  end
  
  def finished
    @finished_monster_fights = current_character.monster_fights.finished
  end

  def show
    if params[:key].present?
      @monster = Monster.find(encryptor.decrypt(params[:key].to_s))
    else
      @monster = current_character.monsters.find(params[:id])
    end

    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)
  end

  def new
    @monster_type = current_character.monster_types.available_for_fight.find(params[:monster_type_id])

    @monster = current_character.monster_fights.own.current.by_type(@monster_type).first
    @monster ||= @monster_type.monsters.create(:character => current_character)
  
    if @monster.new_record?
      flash[:error] = @monster.errors.full_messages
      
      redirect_to monsters_url
    else
      redirect_to monster_url(@monster)
    end
  end

  def update
    @monster = Monster.find(params[:id])
    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

    @power_attack = (!params[:power_attack].blank? && @monster.monster_type.power_attack_enabled?)
    @attack_result = @fight.attack!(@power_attack)

    respond_to do |format|
      format.js
    end
  end

  def reward
    @fight = current_character.monster_fights.find_by_monster_id(params[:id])

    @reward_collected = @fight.collect_reward!
  end
end
