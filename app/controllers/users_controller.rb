class UsersController < ApplicationController
  landing_page :invite, :only => :invite

  def hide_block
    @user = current_user

    if current_user.respond_to?("show_#{ params[:block] }")
      current_user.update_attribute("show_#{ params[:block] }", false)
    end

    render :text => "<!-- no data -->"
  end

  def add_permissions
    @user = current_user

    @user.add_permissions(params[:perms])
    @user.save

    render :text => "OK"
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
    if request.post?
      @sent_invitations = []

      if params[:ids]
        Invitation.transaction do
          params[:ids].each do |receiver|
            invitation = current_user.invitations.create(:receiver_id => receiver)

            @sent_invitations << invitation unless invitation.new_record?
          end
        end

        flash[:success] = t("users.invite.success_message", :amount => @sent_invitations.size)
      end

      redirect_to invite_users_url(:canvas => true)
    elsif params[:from_selector]
      redirect_to root_path
    end
  end
end
