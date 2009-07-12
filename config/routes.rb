ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :item_groups,
      :member => {:move => :post}

    admin.resources :items
    admin.resources :mission_groups
    admin.resources :missions
    admin.resources :property_types
      
    admin.resources :payouts,       :only => [:new]
    admin.resources :requirements,  :only => [:new]
    admin.resources :effects,       :only => [:new]

    admin.resources :newsletters,
      :member => {
        :deliver  => :post,
        :pause    => :post
      }

    admin.resources :promotions
    admin.resources :statistics, :only => :index
  end

  map.root :controller => "characters", :action => "index"

  map.resources(:users,
    :collection => { :invite => :any },
    :member => {
      :narrow_profile_box => :any,
      :wide_profile_box => :any,
      :hide_block => :any
    }
  )

  map.resources(:characters,
    :member => {:upgrade => :any},
    :collection => {:load_vip_money => :any, :rating => :any}
  ) do |character|
    character.resources :assignments, :shallow => true
  end
  map.resources :missions, :member => {:fulfill => :post}
  map.resources :items
  map.resources :item_groups do |group|
    group.resources :items
  end
  map.resources :inventories, 
    :member     => {:place => :any, :use => :any, :take_off => :post},
    :collection => {:placements => :any}
  map.resources :fights
  map.resources :invitations, :member => {:accept => :any, :ignore => :any}
  map.resources :relations
  map.resources :bank_operations
  map.resources :properties

  map.resources :promotions, :only => :show

  map.resource :premium

  map.dynamic_stylesheet "/stylesheets/:id.css", :controller => "pages", :action => "stylesheet", :format => "css"

  map.resources :pages
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
