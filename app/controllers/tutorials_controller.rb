class TutorialsController < ApplicationController
  def step_1
    @missions = Mission.available_for(current_character).all(:limit => 1)

    goal(:tutorial_step_1)
  end

  def step_2
    @item = Item.basic.available_in(:shop).available_for(current_character).first

    goal(:tutorial_step_2)
  end

  def step_3
    @victims = Character.victims_for(current_character).all(:order => "RAND()", :limit => 5)

    goal(:tutorial_step_3)
  end

  def step_4
    # Upgrade list doesn't require any data

    goal(:tutorial_step_4)
  end

  def finish
    current_user.update_attribute(:skip_tutorial, true)

    goal(:tutorial_skip) if params[:premature]

    redirect_to root_path
  end
end
