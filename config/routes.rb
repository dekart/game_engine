ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :item_groups,
      :member => {:move => :post}

    admin.resources :items
    admin.resources :mission_groups
    admin.resources :missions, :collection => {:balance => :any}
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
    admin.resources :stylesheets, :member => {:use => :post, :log => :post}
    admin.resources :tips
    admin.resources :translations
    admin.resources :configurations
    admin.resources :assets
  end

  map.root :controller => "characters", :action => "index"

  map.resource :tutorial, :member => {
    :skip => :any
  }

  map.resources(:users,
    :collection => { :invite => :any },
    :member => {
      :narrow_profile_box => :any,
      :wide_profile_box => :any,
      :hide_block => :any
    }
  )

  map.resources(:characters,
    :member => {:upgrade => :any, :wall => :any},
    :collection => {:load_vip_money => :any, :rating => :any}
  ) do |character|
    character.resources :assignments, :shallow => true
  end

  map.resources :mission_groups, :shallow => true do |group|
    group.resources :missions, :only => :index
  end
  map.resources :missions, :member => {:fulfill => :post}
  
  map.resources :items
  map.resources :item_groups do |group|
    group.resources :items
  end
  map.resources :inventories, 
    :member     => {:use => :any}
  map.resources :fights,
    :collection => {:invite => :post},
    :member     => {:respond => :post, :used_items => :post}
  map.resources :invitations, :member => {:accept => :any, :ignore => :any}
  map.resources :relations
  map.resources :bank_operations
  map.resources :properties

  map.resources :promotions, :only => :show

  map.resource :premium

  map.resources :pages

  map.resources :stylesheets, :only => :show, :member => {:source => :any}

  map.resources :help_requests, :only => [:show, :create]

  map.resources :gifts,
    :member => {:confirm => :any}
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
