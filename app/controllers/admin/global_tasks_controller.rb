class Admin::GlobalTasksController < Admin::BaseController
  helper_method :delete_user_limit

  def delete_users
    if User.count < delete_user_limit
      User.destroy_all
      
      @result = :success
    else
      @result = :failure
    end

    render :layout => false
  end

  def restart
    Rails.restart!

    render :layout => false
  end
  
  def clear_memcache
    Rails.cache.clear

    render :layout => false
  end

  protected

  def delete_user_limit
    100
  end
end
