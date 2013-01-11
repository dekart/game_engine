GameEngine::Application.routes.draw do
  namespace :admin do
    resources :item_groups do
      member do
        put 'change_position'
        put 'change_state'
      end

      resources :items, :only => :index
    end

    resources :items do
      put 'change_state', :on => :member
    end

    resources :mission_groups do
      member do
        put 'change_position'
        put 'change_state'
      end
    end

    resources :missions do
      member do
        put 'change_position'
        put 'change_state'
      end

      resources :mission_levels
    end

    resources :mission_levels, :only => [] do
      put 'change_position', :on => :member
    end

    resources :messages do
      member do
        put 'change_state'
        put 'send_to'
      end
    end

    resources :property_types do
      put 'change_state', :on => :member
    end

    resources :payouts,       :only => [:new]
    resources :requirements,  :only => [:new]
    resources :effects,       :only => [:new]

    resources :promotions
    resources :statistics, :only => :index do
      collection do
        match 'user'
        match 'vip_money'
        match 'level'
        match 'visits'
        match 'payments'
        match 'retention'
        match 'sociality'
        get   'generate_statistics'
      end
    end

    resources :tips do
      put 'change_state', :on => :member
    end

    resources :translations

    resources :character_types do
      put 'change_state', :on => :member
    end

    resources :help_pages do
      put 'change_state', :on => :member
    end

    resources :settings

    resource :global_task do
      member do
        delete 'delete_users'
        post 'restart'
        post 'clear_memcache'
      end
    end

    resources :characters do
      collection do
        match 'search'
        match 'payout'
      end
    end

    resources :users

    resources :vip_money_operations, :only => :index do
      member do
        get :report
      end
    end

    resources :item_collections do
      get 'add_item', :on => :collection
      put 'change_state', :on => :member
    end

    resources :monster_types do
      put 'change_state', :on => :member
    end

    resources :item_sets do
      get 'add_item', :on => :collection
    end

    resources :stories do
      put 'change_state', :on => :member
    end

    resources :global_payouts do
      put 'change_state', :on => :member
    end

    resources :credit_packages do
      put 'change_state', :on => :member
    end

    resources :contests do
      put 'change_state', :on => :member

      resources :contest_groups
    end

    resources :achievement_types do
      put 'change_state', :on => :member
    end

    resources :pictures, :only => [:new]

    resources :complaints, :only => [:index, :show]

    # Add your custom admin routes below this mark
  end

  root :to => 'characters#index'

  resources :users do
    collection do
      match 'subscribe'
      match 'uninstall'
      match 'settings'
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
    resources :items, :only => :index
    resources :inventories, :only => :index
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

    collection do
      match 'optout'
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

    collection do
      match 'service'
      match 'buy_vip'

      match 'refill'
    end
  end

  resource :rating

  resources :gifts, :only => :new

  resources :hit_listings, :only => [:index, :update]

  resources :help_pages, :only => :show

  resources :notifications, :only => [:index] do
    collection do
      post 'disable'
      post 'mark_read'
    end

    collection do
      get 'settings'
      post 'update_settings'
    end
  end

  resources :market_items, :only => [:index, :new, :create, :destroy] do
    post 'buy', :on => :member
  end

  resources :item_collections, :only => [:index, :update]

  resources :monsters do
    member do
      post 'reward'
      match 'status'  
      match 'fighters'
      match 'leaders'
    end

    get 'finished', :on => :collection
  end

  resources :stories, :only => :show

  resources :app_requests do
    put 'ignore', :on => :member
    get 'invite', :on => :collection
  end

  resources :contests, :only => :show do
    member do
      put :collect_reward
    end
  end

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
      get 'apply'
      put 'approve'
      delete 'reject'
    end
  end

  resources :clan_membership_invitations, :only => [:update, :destroy]

  resources :complaints, :only => [:new, :create]

  resources :credit_orders

  match "/character_status" => "character_status#show"
  match "/chats/:chat_id" => "chat_messages#index"
  match "/cil/:key" => "short_links#show"
end
