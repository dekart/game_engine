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
      :missions => @missions.map{|m| m.as_json_for(current_character) }
    }
  end

  def update
    group = GameData::MissionGroup[params[:id]]

    current_character.mission_state.set_current_group(group)

    index
  end
end
