class UsersController < ApplicationController
  skip_before_filter :check_character_existance, :ensure_canvas_connected_to_facebook, :only => :subscribe
  
  landing_page :invite, :only => :invite

  def toggle_block
    @user = current_user

    attribute = "show_#{ params[:block] }"

    if current_user.respond_to?(attribute)
      current_user.update_attribute(attribute, !current_user.send(attribute))
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

      redirect_from_iframe root_url(:canvas => true)
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

      redirect_from_iframe invite_users_url(:canvas => true)
    elsif params[:from_selector]
      redirect_from_iframe root_url(:canvas => true)
    end
  end
  
  def subscribe
    if request.get?
      if params['hub.verify_token'] == Digest::MD5.hexdigest(Facebooker2.secret)
        render :text => params['hub.challenge']
      else
        render :nothing
      end
    elsif request.post?
      facebook_ids = params[:entry].collect{|e| e['id'] }
      
      ids = User.all(:select => 'id', :conditions => {:facebook_id => facebook_ids}).collect{|u| u.id }
      
      Delayed::Job.enqueue Jobs::UserDataUpdate.new(ids)
      
      render :text => 'OK'
    end
  end
end
