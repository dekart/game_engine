module Jobs
  class UpdateReferences
    include Common

    def perform
      facebook_session.server_cache.refresh_ref_url(app_path("stylesheets/profile.css"))
      facebook_session.server_cache.refresh_ref_url(app_path("stylesheets/main.css"))
      facebook_session.server_cache.refresh_ref_url(app_path("pages/show/markup_reference.fbml"))
      facebook_session.server_cache.refresh_ref_url(app_path("pages/show/video_dialog.fbml"))
    end
  end
end