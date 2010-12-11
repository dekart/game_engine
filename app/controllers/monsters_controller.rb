class MonstersController < ApplicationController
  def index
    @monsters       = current_character.monsters.current
    @monster_types  = current_character.monster_types.available_for_fight
  end

  def show
    @monster = Monster.find(params[:id])
    
    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)
  end

  def new
    @monster_type = MonsterType.find(params[:monster_type_id])

    @monster = current_character.monsters.visible.by_type(@monster_type).first
    @monster ||= @monster_type.monsters.create(:character => current_character)

    redirect_to @monster
  end

  def update
    @fight = Monster.find(params[:id]).monster_fights.find_or_initialize_by_character_id(current_character.id)

    @fight.attack!

    render :layout => 'ajax'
  end
end
