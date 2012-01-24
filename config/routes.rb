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
  
  # TODO: change to rails 3 way
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
    
    resources :complaints, :only => [:index, :show]
    
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

  resources :characters do
    member do
      match 'upgrade'
      get 'hospital'
      post 'hospital_heal'
    end
    
    resources :assignments, :shallow => true
    resources :hit_listings, :only => [:new, :create]

    resources :wall_posts, :shallow => true, :only => [:index, :create, :destroy]
  end

  resources :mission_groups, :only => [:index, :show]
  resources :missions, :only => :fulfill do
    collection do
      post 'collect_help_reward'
    end
    
    member do
      post 'fulfill'
      match 'help'
    end
  end
  
  resources :items

  resources :item_groups do
    resources :items
  end
  
  resources :personal_discounts, :only => :update
  
  resources :inventories do
    collection do
      match 'equipment'
      post 'unequip'
      post 'equip'
      match 'give'
    end
    
    member do
      match 'use'
      post 'equip'
      post 'unequip'
      post 'toggle_boost'
      post 'move'
    end
  end
  
  resources :fights do
    member do
      post 'respond'
      post 'used_items'
    end
  end
   
  resources :relations
  
  resources :bank_operations, :only => :new do
    collection do
      post 'deposit'
      post 'withdraw'
    end
  end
  
  resources :properties, :only => [:index, :create] do
    member do
      match 'hire'
      put 'upgrade'
      put 'collect_money'
    end
    
    collection do
      put 'collect_money'
    end
  end

  resources :promotions, :only => :show

  resource :premium do
    get 'change_name', :on => :member
    
    post 'refill_dialog', :on => :collection
  end

  resource :rating

  resources :gifts, :only => :new

  resources :hit_listings, :only => [:index, :update]

  resources :help_pages, :only => :show

  resources :notifications, :only => [] do
    member do
     post 'disable'
    end 
    
    collection do
      post 'settings' 
      post 'update_settings'
    end
  end

  resources :market_items, :only => [:index, :new, :create, :destroy] do
    post 'buy', :on => :member
  end
    
  resources :item_collections, :only => [:index, :update]

  resources :monsters do
    post 'reward', :on => :member
  end
    
  resources :stories, :only => :show
  
  resources :app_requests do
    put 'ignore', :on => :member
  end
  
  resources :contests, :only => :show
  
  resources :exchanges
  
  resources :exchange_offers do
    post 'accept', :on => :member
  end
  
  resource :chat
  
  resources :achievements, :only => [:index, :show, :update]
  
  resources :clans do
    member do
      put 'change_image'
      delete 'delete_member'
    end
  end
  
  resources :clan_members do
    delete 'delete', :on => :member
  end
  
  resources :clan_membership_applications do
    member do
      get 'create'
      put 'approve'
      delete 'reject'
    end
  end
   
  resources :clan_membership_invitations, :only => [:update, :destroy]  
  
  resources :complaints, :only => [:new, :create]

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
