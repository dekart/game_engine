ActionController::Base.session_store = :mem_cache_store

ActionController::Base.session = Rails::Config.session.reverse_merge(
  :expire_after     => 1.day.to_i,
  :httponly         => false,
  :cookie_only      => false
)
