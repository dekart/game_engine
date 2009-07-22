module Jobs
  class UpdateReferences
    include Common

    def perform
      facebook_session.server_cache.refresh_ref_url(app_path("stylesheets/profile.css"))
      facebook_session.server_cache.refresh_ref_url(app_path("stylesheets/main.css"))
    end
  end
end