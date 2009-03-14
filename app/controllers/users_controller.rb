class UsersController < ApplicationController
  before_filter :ensure_application_is_installed_by_facebook_user, :except => [:narrow_profile_box, :wide_profile_box]

  %w{narrow_profile_box wide_profile_box}.each do |box|
    define_method(box) do
      @user = User.find(params[:id])

      render :action => box, :layout => false
    end
  end

  def hide_block
    @user = current_user

    if current_user.respond_to?("show_#{ params[:block] }")
      current_user.update_attribute("show_#{ params[:block] }", false)
    end

    render :text => "<!-- no data -->"
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      flash[:success] = "Your settings have been updated!"

      redirect_to root_url
    else
      render :action => :edit
    end
  end

  def invite
    flash[:success] = "Your invitation has been sent!" if request.post?
  end
end
