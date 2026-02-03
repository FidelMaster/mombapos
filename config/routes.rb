Rails.application.routes.draw do
  resources :menu_items

  get 'reports/sales_summary'
  get 'reports/payment_methods'


  devise_for :users

  authenticated :user do
    get "dashboard/academic"
    root "dashboard#index", as: :authenticated_root
    
    get "reports/sales_summary", to: "reports#sales_summary"
    get "reports/payment_methods", to: "reports#payment_methods"
    get "reports/inventory_impact", to: "reports#inventory_impact"
    get "reports/kardex", to: "reports#kardex"
    resources :areas
    resources :stock_unit_measures
    resources :app_modules
    resources :invoices
    resources :document_account_receivables, path: 'account_receivables', only: [:index, :show]
    resources :stock_movements
    resources :price_lists
    resources :banks
    resources :bank_accounts
    resources :receipts do
      collection do
        get :customer_accounts
      end
    end
    resources :payment_methods
    resources :exchange_rates
    resources :customers
    resources :products do
      resource :product_composition, only: [:edit, :update, :show]
    end
    resources :product_categories
    resources :unit_measures
    resources :suppliers
    resources :warehouses
    resources :branches
    resources :licenses do
      member do
        get :manage_modules
        post :update_modules
      end
    end
    resources :tenants do
      member do
        get :manage_modules
        post :update_modules
      end
    end
    resources :plan_extra_controls
    resources :plan_extra_control_details
    resources :plan_detail_structure_tasks
    resources :plan_detail_structures
    resources :plan_detail_objectives
    resources :plan_details
    resources :plans do
      member do
        get :manage
      end
    end
    resources :objectives
    resources :resources
    resources :group_tasks
    resources :group_members
    resources :groups do
      member do
        get :manage
      end
    end
    resources :specialities
    resources :trainers
    resources :students
    resources :levels

    resources :stock_warehouses
    resources :price_list_items
    resources :orders do
      collection do
        get :history
      end
    end
    get '/pos', to: 'pos#index', as: :pos_index
    get '/pos/pickup', to: 'pos#pickup', as: :pos_pickup
    get '/pos/order/:id', to: 'pos#show_order', as: :pos_order
    get '/pos/:id', to: 'pos#show', as: :pos_table
    resources :dining_tables
  end

  devise_scope :user do
    unauthenticated do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
