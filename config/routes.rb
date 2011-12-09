ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :item_groups,
      :member => {
        :change_position  => :put,
        :change_state     => :put
      } do |group|
        group.resources :items, :only => :index,
          :collection => { :balance => :any }
      end

    admin.resources :items,
      :collection => {
        :balance => :any
      },
      :member => {
        :change_state => :put
      }
    admin.resources :mission_groups,
      :member => {
        :change_position  => :put,
        :change_state     => :put
      }
      
    admin.resources(:missions,
      :collection => {:balance => :any},
      :member => {
        :change_position  => :put,
        :change_state     => :put
      }
    ) do |mission|
      mission.resources :mission_levels
    end
    
    admin.resources :mission_levels, :only => [],
      :member => {
        :change_position => :put
      }
    
    admin.resources :messages,
      :member => {
        :change_state => :put
      }

    admin.resources :bosses,
      :member => {
        :change_state => :put
      }
    admin.resources :property_types,
      :member => {
        :change_state => :put
      }
      
    admin.resources :payouts,       :only => [:new]
    admin.resources :requirements,  :only => [:new]
    admin.resources :effects,       :only => [:new]

    admin.resources :promotions
    admin.resources :statistics, 
      :only => :index,
      :collection => {
        :user       => :any,
        :vip_money  => :any,
        :level      => :any,
        :visits     => :any
      }

    admin.resources :tips,
      :member => {
        :change_state => :put
      }
    admin.resources :translations
    admin.resources :assets

    admin.resources :character_types,
      :member => {
        :change_state => :put
      }

    admin.resources :help_pages,
      :member => {
        :change_state => :put
      }

    admin.resources :settings

    admin.resource :global_task, 
      :member => {
        :delete_users   => :delete,
        :restart        => :post,
        :update_styles  => :post
      }
    admin.resources :characters, :only => [:index, :edit, :update],
      :collection => {
        :search => :any,
        :payout => :any
      }
    admin.resources :users

    admin.resources :vip_money_operations, :only => :index

    admin.resources :titles,
      :member => {
        :change_state => :put
      }

    admin.resources :item_collections,
      :new => {
        :add_item => :any
      },
      :member => {
        :change_state => :put
      }

    admin.resources :monster_types,
      :member => {
        :change_state => :put
      }

    admin.resources :item_sets,
      :new => { :add_item => :any }

    admin.resources :stories,
      :member => {
        :change_state => :put
      }

    admin.resources :global_payouts,
      :member => {
        :change_state => :put
      }
      
    admin.resources :credit_packages,
      :member => {
        :change_state => :put
      }

    admin.resources :contests,
      :member => {
        :change_state => :put
      } do |contest|
      contest.resources :contest_groups
    end
    
    admin.resources :achievement_types,
      :member => {
        :change_state => :put
      }
    
    # Add your custom admin routes below this mark
    
  end

  map.root :controller => "characters", :action => "index"

  map.resources :tutorials,
    :collection => {
      :update_step => :get
    }

  map.resources(:users,
    :collection => {
      :subscribe => :any, 
      :settings => :any
    },
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
      :hospital => :get,
      :hospital_heal => :post,
    }
  ) do |character|
    character.resources :assignments, :shallow => true
    character.resources :hit_listings, :only => [:new, :create]

    character.resources :wall_posts, :shallow => true, :only => [:index, :create, :destroy]
  end

  map.resources :mission_groups, :only => [:index, :show]
  map.resources :missions, 
    :only   => :fulfill,
    :collection => {
      :collect_help_reward => :post
    },
    :member => {
      :fulfill  => :post,
      :help     => :any
    }
  map.resources :boss_fights,
    :only => [:create, :update]
  
  map.resources :items

  map.resources :item_groups do |group|
    group.resources :items
  end
  
  map.resources :personal_discounts, :only => :update
  
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
      :unequip  => :post,
      :toggle_boost => :post,
      :move     => :post
    }
  map.resources :fights,
    :member     => {:respond => :post, :used_items => :post}
  map.resources :relations
  map.resources :bank_operations,
    :only => :new,
    :collection => {
      :deposit  => :post,
      :withdraw => :post
    }
  map.resources :properties, :only => [:index, :create],
    :member => {
      :hire           => :any,
      :upgrade        => :put,
      :collect_money  => :put
    },
    :collection => {
      :collect_money  => :put
    }

  map.resources :promotions, :only => :show

  map.resource :premium, 
    :member => {
      :change_name => :get
    },
    :collection => {
      :refill_dialog => :post
    }

  map.resource :rating

  map.resources :gifts, :only => :new

  map.resources :hit_listings, :only => [:index, :update]

  map.resources :help_pages, :only => :show

  map.resources :notifications, 
    :only => [], 
    :member => {:disable => :post},
    :collection => {
      :settings => :post, 
      :update_settings => :post
    }

  map.resources :market_items,
    :only => [:index, :new, :create, :destroy],
    :member => {
      :buy => :post
    }
  map.resources :item_collections, :only => [:index, :update]

  map.resources :monsters, 
    :member => {:reward => :post}
    
  map.resources :stories, :only => :show
  
  map.resources :app_requests, :member => {:ignore => :put}
  
  map.resources :contests, :only => :show
  
  map.resources :exchanges
  
  map.resources :exchange_offers, 
    :member => {
      :accept => :post
    }
  
  map.resource :chat
  
  map.resources :achievements, :only => [:index, :show, :update]
  
  map.resources :clans,
    :member => {
      :change_image => :put,
      :delete_member => :delete
    }
  
  map.resources :clan_members, :only => :destroy

  # Add your custom routes below this mark
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
