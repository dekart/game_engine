class Admin::UsersController < Admin::BaseController
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_characters_path
      end
    else
      render :edit
    end
  end
end
