GameEngine::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'
  
  namespace :admin do
    resources :item_groups,
      :member => {
        :change_position  => :put,
        :change_state     => :put
      } do
        resources :items, :only => :index,
          :collection => { :balance => :any }
      end

    resources :items,
      :collection => {
        :balance => :any
      },
      :member => {
        :change_state => :put
      }
    resources :mission_groups,
      :member => {
        :change_position  => :put,
        :change_state     => :put
      }
      
    resources(:missions,
      :collection => {:balance => :any},
      :member => {
        :change_position  => :put,
        :change_state     => :put
      }
    ) do
      resources :mission_levels
    end
    
    resources :mission_levels, :only => [],
      :member => {
        :change_position => :put
      }
    
    resources :messages,
      :member => {
        :change_state => :put
      }

    resources :property_types,
      :member => {
        :change_state => :put
      }
      
    resources :payouts,       :only => [:new]
    resources :requirements,  :only => [:new]
    resources :effects,       :only => [:new]

    resources :promotions
    resources :statistics, 
      :only => :index,
      :collection => {
        :user       => :any,
        :vip_money  => :any,
        :level      => :any,
        :visits     => :any
      }

    resources :tips,
      :member => {
        :change_state => :put
      }
    resources :translations
    resources :assets

    resources :character_types,
      :member => {
        :change_state => :put
      }

    resources :help_pages,
      :member => {
        :change_state => :put
      }

    resources :settings

    resource :global_task, 
      :member => {
        :delete_users   => :delete,
        :restart        => :post,
        :update_styles  => :post,
        :clear_memcache => :post
      }
    resources :characters, :only => [:index, :edit, :update],
      :collection => {
        :search => :any,
        :payout => :any
      }
    resources :users

    resources :vip_money_operations, :only => :index

    resources :item_collections,
      :new => {
        :add_item => :any
      },
      :member => {
        :change_state => :put
      }

    resources :monster_types,
      :member => {
        :change_state => :put
      }

    resources :item_sets,
      :new => { :add_item => :any }

    resources :stories,
      :member => {
        :change_state => :put
      }

    resources :global_payouts,
      :member => {
        :change_state => :put
      }
      
    resources :credit_packages,
      :member => {
        :change_state => :put
      }

    resources :contests,
      :member => {
        :change_state => :put
      } do
      resources :contest_groups
    end
    
    resources :achievement_types,
      :member => {
        :change_state => :put
      }
    
    resources :pictures, :only => [:new]
    
    # Add your custom admin routes below this mark
  end
  
  root :to => 'characters#index'

  resources :users do
    collection do
      match 'subscribe'
      match 'settings'
    end
    
    member do
      match 'toggle_block'
    end
  end

  resources(:characters,
    :member => {
      :upgrade  => :any,
      :hospital => :get,
      :hospital_heal => :post,
    }
  ) do
    resources :assignments, :shallow => true
    resources :hit_listings, :only => [:new, :create]

    resources :wall_posts, :shallow => true, :only => [:index, :create, :destroy]
  end

  resources :mission_groups, :only => [:index, :show]
  resources :missions, 
    :only   => :fulfill,
    :collection => {
      :collect_help_reward => :post
    },
    :member => {
      :fulfill  => :post,
      :help     => :any
    }
  
  resources :items

  resources :item_groups do
    resources :items
  end
  
  resources :personal_discounts, :only => :update
  
  resources :inventories,
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
  resources :fights,
    :member     => {:respond => :post, :used_items => :post}
  resources :relations
  resources :bank_operations,
    :only => :new,
    :collection => {
      :deposit  => :post,
      :withdraw => :post
    }
  resources :properties, :only => [:index, :create],
    :member => {
      :hire           => :any,
      :upgrade        => :put,
      :collect_money  => :put
    },
    :collection => {
      :collect_money  => :put
    }

  resources :promotions, :only => :show

  resource :premium, 
    :member => {
      :change_name => :get
    },
    :collection => {
      :refill_dialog => :post
    }

  resource :rating

  resources :gifts, :only => :new

  resources :hit_listings, :only => [:index, :update]

  resources :help_pages, :only => :show

  resources :notifications, 
    :only => [], 
    :member => {:disable => :post},
    :collection => {
      :settings => :post, 
      :update_settings => :post
    }

  resources :market_items,
    :only => [:index, :new, :create, :destroy],
    :member => {
      :buy => :post
    }
  resources :item_collections, :only => [:index, :update]

  resources :monsters, 
    :member => {:reward => :post}
    
  resources :stories, :only => :show
  
  resources :app_requests, :member => {:ignore => :put}
  
  resources :contests, :only => :show
  
  resources :exchanges
  
  resources :exchange_offers, 
    :member => {
      :accept => :post
    }
  
  resource :chat
  
  resources :achievements, :only => [:index, :show, :update]
  
  resources :clans,
    :member => {
      :change_image => :put,
      :delete_member => :delete
    }
  
  resources :clan_members,
    :member => {
      :delete => :delete
    }
  
  resources :clan_membership_applications,
    :member => {
      :create => :get,
      :approve => :put,
      :reject => :delete
    }
   
  resources :clan_membership_invitations, :only => [:update, :destroy]  

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
