ActionController::Routing::Routes.draw do |map|
  map.facepalm_oauth_endpoint '/facebook_oauth',
    :controller => :application,
    :action     => :facepalm_oauth_endpoint
end