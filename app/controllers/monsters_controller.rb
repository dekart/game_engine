class MonstersController < ApplicationController
  def index
    @defeated_monster_fights = current_character.monster_fights.defeated
    @active_monster_fights   = current_character.monster_fights.active
    
    @locked_monster = current_character.monster_types.available_in_future.first
    @monster_types  = current_character.monster_types.available_for_fight

    render :json => {
      :defeated => @defeated_monster_fights.as_json,
      :active   => @active_monster_fights.as_json,
      :locked   => @locked_monster.as_json(current_character),
      :monster_types => @monster_types.as_json(current_character)
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
      :fighters => @monster.damage.leaders.collect{|char, damage| [char.facebook_id, damage]}.as_json
    }
  end

  def new
    @monster_type = current_character.monster_types.available_for_fight.find(params[:monster_type_id])

    @monster = current_character.monster_fights.own.current.by_type(@monster_type).first
    @monster ||= @monster_type.monsters.create(:character => current_character)
  
    if @monster.new_record?
      flash[:error] = @monster.errors.full_messages
      
      redirect_to monsters_url
    else
      @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

      render :json => {
        :monster  => @monster.as_json,
        :fight    => @fight.as_json,
        :fighters => @monster.damage.leaders.collect{|char, damage| [char.facebook_id, damage]}.as_json
      }
    end
  end

  def update
    @monster = Monster.find(params[:id])
    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

    @power_attack = (!params[:power_attack].blank? && @monster.monster_type.power_attack_enabled?)
    @attack_result = @fight.attack!(@power_attack)

    if @fight.errors.empty?
      render :json => {
        :success       => true,
        :monster       => @monster.as_json,
        :fight         => @fight.as_json,
        :power_attack  => @power_attack,
        :attack_result => @attack_result
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
      :monster => @fight.monster.as_json,
      :fight   => @fight.as_json,
      :reward  => result ? @fight.payouts.preview(triggers) : {},
      :reward_collected => result
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
      :fighters => @monster.damage.leaders
    }
  end
end
