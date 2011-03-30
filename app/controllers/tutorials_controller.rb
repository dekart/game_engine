class TutorialsController < ApplicationController
  # def show
  #   @current_step = params[:id]
  # 
  #   render :partial => "tutorials/block", :layout => false
  # end
  
  def update_step
    current_user.update_attribute(:tutorial_step, params[:tutorial_step])
    render :partial => "tutorials/block", :layout => "ajax"
  end
  
  
end
