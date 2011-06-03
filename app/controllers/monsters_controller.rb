class MonstersController < ApplicationController
  def index
    @monsters       = current_character.monsters.current
    @monster_types  = current_character.monster_types.available_for_fight
    @locked_monster   = current_character.monster_types.available_in_future.first
    
    render :index
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

    @monster = current_character.monsters.own.current.by_type(@monster_type).first
    @monster ||= @monster_type.monsters.create(:character => current_character)
  
    if @monster.new_record?
      flash.now[:error] = @monster.errors.full_messages
      
      index
    else
      EventLoggingService.log_event(:monster_engaged, @monster)

      redirect_from_iframe monster_url(@monster, :canvas => true)
    end
  end

  def update
    @monster = Monster.find(params[:id])
    @fight = @monster.monster_fights.find_or_initialize_by_character_id(current_character.id)

    @power_attack = (params[:power_attack] != nil)
    @attack_result = @fight.attack!(@power_attack)

    if @attack_result
      if @fight.monster.progress?
        EventLoggingService.log_event(:monster_attacked, @fight)
      elsif @fight.monster.won?
        EventLoggingService.log_event(:monster_killed, @fight)
      end
    end

    render :layout => 'ajax'
  end

  def reward
    @fight = current_character.monster_fights.find_by_monster_id(params[:id])

    @reward_collected = @fight.collect_reward!

    if @reward_collected
      EventLoggingService.log_event(:reward_collected, @fight)
    end

    render :layout => 'ajax'
  end

end
