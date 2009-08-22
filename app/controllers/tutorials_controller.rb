class TutorialsController < ApplicationController
  def step_1
    @mission = Mission.available_for(current_character).first
  end

  def step_2
    @item = Item.basic.available_in(:shop).available_for(current_character).first
  end

  def step_3
    @inventories = current_character.inventories.available
  end

  def step_4
    @victims = Character.victims_for(current_character).all(:order => "RAND()", :limit => 5)
  end

  def step_5
    # Upgrade list doesn't require any data
  end

  def finish
    current_user.update_attribute(:skip_tutorial, true)

    redirect_to root_path
  end
end
