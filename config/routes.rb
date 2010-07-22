ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :item_groups,
      :member => {
        :move     => :put,
        :publish  => :put,
        :hide     => :put
      } do |group|
        group.resources :items, :only => :index
      end

    admin.resources :items,
      :member => {
        :publish  => :put,
        :hide     => :put
      }
    admin.resources :mission_groups,
      :member => {
        :publish  => :put,
        :hide     => :put
      }
    admin.resources :missions, 
      :collection => {:balance => :any},
      :member => {
        :publish  => :put,
        :hide     => :put
      }
    admin.resources :bosses,
      :member => {
        :publish  => :put,
        :hide     => :put
      }
    admin.resources :property_types,
      :member => {
        :publish  => :put,
        :hide     => :put
      }
      
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
    admin.resources :skins,
      :member => {:activate => :post, :changelog => :post}
    admin.resources :tips
    admin.resources :translations
    admin.resources :assets

    admin.resources :character_types,
      :member => {
        :publish  => :put,
        :hide     => :put
      }

    admin.resources :help_pages,
      :member => {
        :publish  => :put,
        :hide     => :put
      }

    admin.resources :settings

    admin.resource :global_task, 
      :member => {
        :delete_users => :delete,
        :restart      => :post
      }
  end

  map.root :controller => "characters", :action => "index"

  map.resources :tutorials, :only => :show

  map.resources(:users,
    :collection => { :invite => :any },
    :member => {
      :narrow_profile_box => :any,
      :wide_profile_box => :any,
      :hide_block => :any,
      :add_permissions => :any
    }
  )

  map.resources(:characters,
    :member => {
      :upgrade => :any
    },
    :collection => {
      :load_vip_money => :any
    }
  ) do |character|
    character.resources :assignments, :shallow => true
    character.resources :hit_listings, :only => [:new, :create]
  end

  map.resources :mission_groups, :only => [:index, :show]
  map.resources :missions, 
    :only   => :fulfill,
    :member => {:fulfill => :post}
  map.resources :boss_fights,
    :only => [:create, :update]
  
  map.resources :items
  map.resources :item_groups do |group|
    group.resources :items
  end
  map.resources :inventories,
    :collection => {:equipment => :any},
    :member     => {
      :use      => :any,
      :equip    => :post,
      :unequip  => :post
    }
  map.resources :fights,
    :member     => {:respond => :post, :used_items => :post}
  map.resources :invitations, :member => {:accept => :any, :ignore => :any}
  map.resources :relations
  map.resources :bank_operations,
    :only => :new,
    :collection => {
      :deposit  => :post,
      :withdraw => :post
    }
  map.resources :properties, :only => [:index, :create],
    :member => {
      :upgrade        => :put,
      :collect_money  => :put
    },
    :collection => {
      :collect_money  => :put
    }

  map.resources :promotions, :only => :show

  map.resource :premium

  map.resource :rating, :member => {:global => :any}

  map.resources :help_requests, :only => [:show, :create]

  map.resources :gifts,
    :member => {:confirm => :any}

  map.resources :hit_listings, :only => [:index, :update]

  map.resources :help_pages, :only => :show
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
