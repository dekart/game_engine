class MonstersController < ApplicationController
  def index
    @monsters       = current_character.monsters.with_state(:progress)
    @monster_types  = current_character.monster_types.available
  end

  def show
    @monster = current_character.monsters.find(params[:id])
  end

  def create
    @monster_type = MonsterType.find(params[:monster_type_id])

    @monster = @monster_type.monsters.create(:character => current_character)

    redirect_to @monster
  end

  def update
    @monster = Monster.find(params[:id])

    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

    @fight.attack!

    render :layout => 'ajax'
  end
end
