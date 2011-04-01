ActionController::Base.cache_store = :mem_cache_store, Rails::Config.cache.server, {:namespace => Rails.env}
