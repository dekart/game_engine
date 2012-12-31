class MissionGroupsController < ApplicationController
  def index
    @groups = GameData::MissionGroup.select{|g| g.visible?(current_character) }

    @current_group = current_character.mission_state.current_group || @groups.first

    @missions = @current_group.missions.select{|m| m.visible?(current_character) }

    render :json => {
      :groups => @groups.map{|g|
        g.as_json.tap do |r|
          r[:current] = true if g == @current_group
          r[:requirements] = g.requirements(current_character)
        end
      },
      :missions => @missions.map{|m|
        level = current_character.mission_state.level_for(m)

        logger.debug level.requirements(current_character).to_json.inspect

        m.as_json.merge!(
          :level => level.as_json.merge!(
            :progress => current_character.mission_state.progress_for(level),
            :requirements => level.requirements(current_character),
            :rewards => {
              :success => level.preview_reward_on(:success, current_character),
              :repeat_success => level.preview_reward_on(:repeat_success, current_character)
            }
          )
        )
      }
    }
  end

  def update
    group = GameData::MissionGroup[params[:id]]

    current_character.mission_state.set_current_group(group)

    index
  end
end
