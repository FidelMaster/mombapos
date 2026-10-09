Rails.application.routes.draw do
  # ==============================================================================
  # 1. AUTENTICACIÓN (Devise)
  # ==============================================================================
  devise_for :users

  # ==============================================================================
  # 2. RAÍZ DINÁMICA (Dashboard si está logueado / Landing si no)
  # ==============================================================================
  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  unauthenticated do
    root "pages#home", as: :unauthenticated_root
  end

  root "pages#home"

  # Páginas estáticas informativas (Footer / Legal)
  get "/terms",   to: "pages#terms"
  get "/privacy", to: "pages#privacy"
  get "/support", to: "pages#support"

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  # ==============================================================================
  # 3. RUTAS OPERATIVAS DEL SAAS
  # (Se definen aquí para que existan siempre. La protección de login la maneja
  # ApplicationController con before_action :authenticate_user!)
  # ==============================================================================
  
  # --- Dashboard & Reportes ---
  get "dashboard/academic", to: "dashboard#academic"
  
  scope :reports, as: :reports do
    get :sales_summary,    to: "reports#sales_summary"
    get :payment_methods,  to: "reports#payment_methods"
    get :inventory_impact, to: "reports#inventory_impact"
    get :kardex,           to: "reports#kardex"
  end

  # --- Punto de Venta (POS) & Restaurante ---
  get "/pos",           to: "pos#index",      as: :pos_index
  get "/pos/pickup",    to: "pos#pickup",     as: :pos_pickup
  get "/pos/order/:id", to: "pos#show_order", as: :pos_order
  get "/pos/:id",       to: "pos#show",       as: :pos_table
  resources :dining_tables

  # --- Facturación, Cobros y Finanzas ---
  resources :invoices do
    member do
      post :annull
    end
  end

  resources :document_account_receivables, path: "account_receivables", as: :account_receivables, only: [:index, :show]

  resources :receipts do
    collection do
      get :customer_accounts
    end
  end

  resources :payment_methods
  resources :exchange_rates
  resources :banks
  resources :bank_accounts

  # --- Pedidos, Cotizaciones y Taller ---
  resources :orders do
    collection do
      get :history
    end
    member do
      patch :transition
      get :quotation
    end
    resources :order_advances, only: [:create, :destroy], path: "advances"
  end

  # --- Catálogo de Productos y Precios ---
  resources :products do
    resource :product_composition, only: [:edit, :update, :show]
    resources :product_variants, path: "variants"
  end
  resources :product_categories
  resources :price_lists
  resources :price_list_items
  resources :menu_items

  # --- Inventario, Bodegas y Unidades ---
  resources :warehouses
  resources :stock_warehouses
  resources :stock_movements
  resources :unit_measures
  resources :stock_unit_measures

  # --- Clientes y Proveedores ---
  resources :customers
  resources :suppliers

  # --- Multi-tenant, Licencias y Sucursales ---
  resources :branches
  resources :tenants do
    member do
      get    :manage_modules
      post   :update_modules
      get    :manage_users
      post   :create_user
      patch  :toggle_user_status
      delete :destroy_user
      patch  :toggle_active
    end
  end
  resources :licenses do
    member do
      get  :manage_modules
      post :update_modules
    end
  end

  # --- Administración y Permisos ---
  resources :users
  resources :roles
  resources :areas
  resources :app_modules

  # --- Módulo Académico / Entrenamiento ---
  resources :plans do
    member do
      get :manage
    end
  end
  resources :plan_details
  resources :plan_detail_objectives
  resources :plan_detail_structures
  resources :plan_detail_structure_tasks
  resources :plan_extra_controls
  resources :plan_extra_control_details
  resources :objectives
  resources :resources
  resources :groups do
    member do
      get :manage
    end
  end
  resources :group_tasks
  resources :group_members
  resources :trainers
  resources :students
  resources :specialities
  resources :levels
end