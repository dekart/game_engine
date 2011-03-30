class TutorialsController < ApplicationController
  
  def update_step
    current_user.update_attribute(:tutorial_step, params[:tutorial_step])
    render :partial => "tutorials/block", :layout => "ajax"
  end
end
