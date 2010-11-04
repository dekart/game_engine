ActionController::Base.session = {
  :key              => '_game_engine2',
  :secret           => 'ab08c85360590a72ea4c70ff82fcf09714f333ba13723cb9f477eb8f50c7dd4f3328ca981cc7ee2df27367f6daeedd29c51cb00fb5fc3bf146ab1e90ccb1f878',
  :expire_after     => 1.day.to_i,
  :memcache_server  => SESSION_SERVER,
  :httponly         => false,
  :cookie_only      => false
}

ActionController::Base.session_store = :mem_cache_store_with_headers