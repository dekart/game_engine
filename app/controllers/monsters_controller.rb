class MonstersController < ApplicationController
  def index
    @defeated_monster_fights = current_character.monster_fights.defeated
    @active_monster_fights   = current_character.monster_fights.active

    @locked_monster = GameData::MonsterType.select{|t| t.locked_for?(current_character) }.sort_by{|t| t.level.to_i }.first
    @monster_types  = GameData::MonsterType.select{|t| t.visible?(current_character) }

    render :json => {
      :defeated => @defeated_monster_fights.as_json,
      :active   => @active_monster_fights.as_json,
      :locked   => @locked_monster.as_json(current_character),
      :monster_types => @monster_types.map{|t| t.as_json_for(current_character) }
    }
  end

  def finished
    @finished_monster_fights = current_character.monster_fights.finished

    render :json => {
      :finished => @finished_monster_fights.as_json
    }
  end

  def show
    if params[:key].present?
      @monster = Monster.find(encryptor.decrypt(params[:key].to_s))
    else
      @monster = current_character.monsters.find(params[:id])
    end

    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

    render :json => {
      :monster  => @monster.as_json,
      :fight    => @fight.as_json,
      :fighters => @monster.fighters(current_character).as_json,
      :leaders  => @monster.damage.leaders_as_json
    }
  end

  def new
    @monster_type = GameData::MonsterType[params[:monster_type_id]]

    @monster = current_character.monster_fights.own.current.by_type(@monster_type).first
    @monster ||= Monster.create(:monster_type => @monster_type, :character => current_character)

    if @monster.new_record?
      flash[:error] = @monster.errors.full_messages

      redirect_to monsters_url
    else
      @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

      render :json => {
        :monster  => @monster.as_json,
        :fight    => @fight.as_json,
        :fighters => @monster.fighters(current_character).as_json,
        :leaders  => @monster.damage.leaders_as_json
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
        :success          => true,
        :monster_damage   => @fight.monster_damage,
        :character_damage => @fight.character_damage,
        :boosts           => @fight.boosts,
        :character        => @fight.character.as_json_for_overview
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
    triggers = @fight.payout_triggers

    result = @fight.collect_reward!

    render :json => {
      :rewards => @fight.payouts
    }
  end

  def status
    @monster = Monster.find(params[:id])

    render :json => {
      :hp             => @monster.hp,
      :time_remaining => @monster.time_remaining,
      :image_url      => @monster.pictures.url(:small),
      :description    => @monster.description
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
end
