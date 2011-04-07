class TutorialsController < ApplicationController
  
  def update_step
    current_user.update_attribute(:tutorial_step, params[:tutorial_step])
    
    # flash[:show_tutorial] = true
    flash.now[:tutorial_step_updated] = true
    
    render :partial => "tutorials/block", :layout => "ajax"
  end
end
