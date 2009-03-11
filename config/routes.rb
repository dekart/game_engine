ActionController::Routing::Routes.draw do |map|
  map.root :controller => "characters", :action => "index"

  map.resources(:users,
    :collection => { :invite => :any },
    :member => {
      :narrow_profile_box => :any,
      :wide_profile_box => :any,
      :hide_block => :any
    }
  )

  map.resources :missions, :member => {:fulfill => :post}

  map.dynamic_stylesheet "/stylesheets/:id.css", :controller => "pages", :action => "stylesheet", :format => "css"

  map.resources :pages
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
