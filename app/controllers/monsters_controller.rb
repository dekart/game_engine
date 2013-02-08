class MonstersController < ApplicationController
  def index
    @defeated_monster_fights = current_character.monsters.defeated_fights
    @active_monster_fights   = current_character.monsters.active_fights

    @locked_monster = current_character.monsters.locked_monster_types.first
    @monster_types  = current_character.monsters.available_monster_types

    render :json => {
      :defeated => @defeated_monster_fights.as_json,
      :active   => @active_monster_fights.as_json,
      :locked   => @locked_monster.as_json(current_character),
      :monster_types => @monster_types.map{|t| t.as_json_for(current_character) }
    }
  end

  def finished
    @finished_monster_fights = current_character.monsters.finished_fights

    render :json => {
      :finished => @finished_monster_fights.as_json
    }
  end

  def show
    if params[:key].present?
      @monster = Monster.find(encryptor.decrypt(params[:key].to_s))
    else
      @monster = current_character.monsters[params[:id]]
    end

    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

    render :json => {
      :fight    => @fight.as_json,
      :fighters => @monster.fighters(current_character).as_json,
      :leaders  => @monster.damage.as_json,
      :boosts   => boosts
    }
  end

  def create
    @monster_type = GameData::MonsterType[params[:monster_type_id]]

    @monster = current_character.monster_fights.own.current.by_type(@monster_type).first
    @monster ||= Monster.create(:monster_type => @monster_type, :character => current_character)

    if @monster.new_record?
      flash[:error] = @monster.errors.full_messages

      redirect_to monsters_url
    else
      @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

      render :json => {
        :fight    => @fight.as_json,
        :fighters => @monster.fighters(current_character).as_json,
        :leaders  => @monster.damage.as_json,
        :boosts   => boosts
      }
    end
  end

  def update
    @monster = Monster.find(params[:id])
    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

    power_attack = params[:power_attack].present?
    boost = params[:boost].to_i unless params[:boost].blank?

    @attack_result = @fight.attack!(boost, power_attack)

    if @fight.errors.empty?
      render :json => {
        :success    => true,
        :result     => @fight.as_json_for_attack,
        :boosts     => boosts,
        :character  => @fight.character.as_json_for_overview
      }
    else
      render :json => {
        :success => false,
        :refill  => @fight.errors.full_messages.first
      }
    end
  end

  def reward
    @fight = current_character.monster_fights.find_by_monster_id(params[:id])

    result = @fight.collect_reward!

    render :json => {
      :rewards => result
    }
  end

  def status
    @monster = Monster.find(params[:id])

    render :json => {
      :hp             => @monster.hp,
      :time_remaining => @monster.time_remaining
    }
  end

  def fighters
    @monster = Monster.find(params[:id])

    render :json => {
      :fighters => @monster.fighters(current_character).as_json
    }
  end

  def leaders
    @monster = Monster.find(params[:id])

    render :json => {
      :leaders => @monster.damage.leaders_as_json
    }
  end

  private

  # FIXME: improper place for this
  def boosts
    current_character.boosts.for(:monster, :attack).
    sort_by{ |i| i.item.effect(:damage) }.reverse[0..1].
    map{ |i| [i.item_id, i.amount, i.item.effect(:damage), i.pictures.url(:medium)] }
  end
end
