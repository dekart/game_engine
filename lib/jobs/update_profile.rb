module Jobs
  class UpdateProfile < Struct.new(:user_id)
    include Common

    def perform
      user = User.find(user_id)

      facebook_session.server_cache.refresh_ref_url(app_path("users/" + user.id.to_s + "/narrow_profile_box.fbml"))
      facebook_session.server_cache.refresh_ref_url(app_path("users/" + user.id.to_s + "/wide_profile_box.fbml"))
    end
  end
end