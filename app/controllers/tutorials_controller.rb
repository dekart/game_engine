class TutorialsController < ApplicationController
  
  def update_step
    current_user.update_attribute(:tutorial_step, Tutorial.next_step(current_user.tutorial_step))
    
    if params[:redirect_to]
      flash[:show_tutorial] = true
      redirect_to URI.decode(params[:redirect_to])
    else
      flash.now[:show_tutorial] = true
      render :partial => "tutorials/block", :layout => "ajax"
    end
  end
  
end
