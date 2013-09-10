class UsersController < ApplicationController
  skip_authentication_filters :only => [:subscribe, :uninstall]
  skip_before_filter :tracking_requests, :check_standalone, :only => [:subscribe, :uninstall]

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

      redirect_to root_url
    else
      render :action => :edit
    end
  end


  def subscribe
    if request.get?
      render :text => Koala::Facebook::RealtimeUpdates.meet_challenge(params, facepalm.subscription_token)
    elsif request.post?
      facebook_ids = params[:entry].collect{|e| e['id'] }

      ids = User.all(:select => 'id', :conditions => {:facebook_id => facebook_ids}).collect{|u| u.id }

      Delayed::Job.enqueue Jobs::UserDataUpdate.new(ids)

      render :text => 'OK'
    end
  end

  def uninstall
    user = User.find_by_facebook_id(current_facebook_user.uid)

    user.update_attribute(:installed, false)

    render :text => 'OK'
  end

  def settings
  end
end
