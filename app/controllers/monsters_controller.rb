class MonstersController < ApplicationController
  def index
    @monsters       = current_character.monsters.current
    @monster_types  = current_character.monster_types.available_for_fight
  end

  def show
    if params[:key].present?
      @monster = Monster.find(encryptor.decrypt(params[:key].to_s))
    else
      @monster = current_character.monsters.find(params[:id])
    end

    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    Rails.logger.error "Failed to decrypt monster ID: #{ params[:id] }"

    redirect_from_exception
  end

  def new
    @monster_type = MonsterType.find(params[:monster_type_id])

    @monster = current_character.monsters.current.by_type(@monster_type).first
    @monster ||= @monster_type.monsters.create!(:character => current_character)
  
    EventLoggingService.log_event(:monster_engaged, engage_event_data(@monster))

    redirect_to @monster
  end

  def update
    @monster = Monster.find(params[:id])
    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

    @attack_result = @fight.attack!

    if @attack_result
      if @fight.monster.progress?
        EventLoggingService.log_event(:monster_attacked, attack_event_data(@monster))
      elsif @fight.monster.won?
        EventLoggingService.log_event(:monster_killed, attack_event_data(@monster))
      end
    end

    render :layout => 'ajax'
  end

  def reward
    @fight = current_character.monster_fights.find_by_monster_id(params[:id])

    @reward_collected = @fight.collect_reward!

    if @reward_collected
      EventLoggingService.log_event(:reward_collected, reward_event_data(@fight))
    end

    render :layout => 'ajax'
  end

  protected

  def engage_event_data(monster)
    {
      :monster_id => monster.id,
      :monster_type_id => monster.monster_type_id,
      :character_id => monster.character.id,
      :character_level => monster.character.level
    }.to_json
  end

  def attack_event_data(fight)
    monster = fight.monster
    {
      :monster_id => monster.id,
      :monster_type_id => monster.monster_type_id,
      :character_id => monster.character.id,
      :character_level => monster.character.level,
      :monster_damage => fight.monster_damage,
      :character_damage => fight.character_damage,
      :money => fight.money,
      :experience => fight.experience
    }.to_json
  end

  def reward_event_data(fight)
    monster = fight.monster
    {
      :monster_id => monster.id,
      :monster_type_id => monster.monster_type_id,
      :character_id => monster.character.id,
      :character_level => monster.character.level
    }.to_json
  end
end
