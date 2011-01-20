ActionController::Routing::Routes.draw do |map|
  map.facebook_oauth_connect '/facebook_oauth',
    :controller => :application,
    :action     => :facebook_oauth_connect

  map.namespace :admin do |admin|
    admin.resources :item_groups,
      :member => {
        :move     => :put,
        :publish  => :put,
        :hide     => :put
      } do |group|
        group.resources :items, :only => :index,
          :collection => { :balance => :any }
      end

    admin.resources :items,
      :collection => {
        :balance => :any
      },
      :member => {
        :publish  => :put,
        :hide     => :put
      }
    admin.resources :mission_groups,
      :member => {
        :move     => :put,
        :publish  => :put,
        :hide     => :put
      }
      
    admin.resources(:missions,
      :collection => {:balance => :any},
      :member => {
        :publish  => :put,
        :hide     => :put,
        :move     => :put
      }
    ) do |mission|
      mission.resources :mission_levels,
        :member => {
          :move => :put
        }
    end

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
    admin.resources :statistics, 
      :only => :index,
      :collection => {
        :user       => :any,
        :vip_money  => :any
      }
    admin.resources :skins,
      :member => {:activate => :post, :changelog => :post}
    admin.resources :tips,
      :member => {
        :publish  => :put,
        :hide     => :put
      }
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
    admin.resources :characters, :only => [:index, :edit, :update],
      :collection => {
        :search => :any,
        :payout => :any
      }

    admin.resources :vip_money_operations, :only => :index

    admin.resources :titles,
      :member => {
        :publish  => :put,
        :hide     => :put
      }

    admin.resources :item_collections,
      :new => {
        :add_item => :any
      },
      :member => {
        :publish  => :put,
        :hide     => :put
      }

    admin.resources :monster_types,
      :member => {
        :publish  => :put,
        :hide     => :put
      }

    admin.resources :item_sets,
      :new => { :add_item => :any }

    # Add your custom admin routes below this mark
    
  end

  map.root :controller => "characters", :action => "index"

  map.resources :tutorials, :only => :show

  map.resources(:users,
    :collection => { :invite => :any, :subscribe => :any },
    :member => {
      :toggle_block => :any
    }
  )

  #TODO: Remove this deprecated route when updating system to major version
  map.connect 'characters/load_vip_money',
    :controller => 'vip_money_operations',
    :action     => 'load_money'

  map.resources(:characters,
    :member => {
      :upgrade  => :any,
      :hospital => :any
    }
  ) do |character|
    character.resources :assignments, :shallow => true
    character.resources :hit_listings, :only => [:new, :create]

    character.resources :wall_posts, :shallow => true, :only => [:index, :create, :destroy]
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
    :collection => {
      :equipment  => :any,
      :unequip    => :post,
      :equip      => :post,
      :give       => :any
    },
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

  map.resources :notifications, :only => [], :member => {:disable => :post}

  map.resources :market_items,
    :only => [:index, :new, :create, :destroy],
    :member => {
      :buy => :post
    }
  map.resources :item_collections, :only => [:index, :update]

  map.resources :monsters, 
    :member => {:reward => :post}

  # Add your custom routes below this mark
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
