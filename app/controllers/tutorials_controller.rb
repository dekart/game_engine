class TutorialsController < ApplicationController
  helper_method :tutorial?

  def step_1
    @missions = Mission.available_for(current_character).all(:limit => 1)
  end

  def step_2
    @item = Item.available.basic.available_in(:shop).available_for(current_character).first
  end

  def step_3
    @victims = Character.victims_for(current_character).all(:order => "RAND()", :limit => 5)
  end

  def step_4
    # Upgrade list doesn't require any data
  end

  def finish
    current_user.update_attribute(:skip_tutorial, true)

    redirect_to root_path
  end

  protected

  def tutorial?
    true
  end
end
