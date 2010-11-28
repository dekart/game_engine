class MonstersController < ApplicationController
  def index
    @monster_types = current_character.monster_types.available
  end

  def show
    @monster = current_character.monsters.find(params[:id])
  end

  def create
    @monster_type = MonsterType.find(params[:monster_type_id])

    @monster = current_character.monsters.create(:monster_type => @monster_type)

    redirect_to @monster
  end
end
