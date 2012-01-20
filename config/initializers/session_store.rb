Rails.application.config.session_store = :mem_cache_store

Rails.application.config.session_options = Rails::Config.session.reverse_merge(
  :expire_after     => 1.day.to_i,
  :httponly         => false,
  :cookie_only      => false
)
