ActionController::Routing::Routes.draw do |map|
  map.root :controller => "users", :action => "show"

  map.resources(:users,
    :collection => { :invite => :any },
    :member => {
      :narrow_profile_box => :any,
      :wide_profile_box => :any,
      :hide_block => :any
    }
  ) do |user|
  end

  map.dynamic_stylesheet "/stylesheets/:id.css", :controller => "pages", :action => "stylesheet", :format => "css"

  map.resources :pages
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
