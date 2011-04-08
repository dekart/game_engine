class TutorialsController < ApplicationController
  
  def update_step
    current_user.update_attribute(:tutorial_step, Tutorial.next_step(current_user.tutorial_step))
    
    if params[:redirect_to]
      flash[:tutorial_step_updated] = true
      redirect_to URI.decode(params[:redirect_to])
    else
      flash.now[:tutorial_step_updated] = true
      render :partial => "tutorials/block", :layout => "ajax"
    end
  end
  
end
