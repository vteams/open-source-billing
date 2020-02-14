require 'sidekiq/web'
Osb::Application.routes.draw do

  resources :notifications, only: :index

  get 'activities/index'

  mount OsbApi::Engine => "/api"
  mount GrapeSwaggerRails::Engine => '/api/docs'
  use_doorkeeper :scope => 'developer'

  mount Sidekiq::Web => '/sidekiq'

  #namespace :OpenSourceBilling do
  #  resources :people
  #end
  #get '/auth/:provider/callback', to: 'sessions#create'
  scope "(:locale)" do
    get '/', to: redirect{Rails.application.routes.url_helpers.new_user_session_path}

    resources :tasks do
      collection do
        get 'bulk_actions'
        get 'filter_items'
        get 'undo_actions'
        post 'load_task_data'
      end
    end

    resources :staffs do
      collection do
        get 'bulk_actions'
        get 'filter_items'
        get 'undo_actions'
        post 'load_staff_data'
      end
    end

    resources :companies do
      collection do
        get 'bulk_actions'
        post 'get_clients_and_items'
        get 'filter_companies'
        get 'undo_actions'
        get :settings_listing
        delete :destroy_bulk
      end
      member do
        get 'select'
      end
    end

    resources :sub_users do
      collection do
        get 'user_settings'
        get :settings_listing
        delete :destroy_bulk
      end
    end

    resources :masquerades, only: [:create, :destroy]

    #API authentication for create invoice and clients
    post '/token_authentication', to: 'authenticate#token'

    resources :settings do
      member do
        get 'set_default_currency'
      end
      collection do
        post :nav_format
        resources :roles
        get :invoice_number_format
      end
    end

    resources :roles do
      collection do
        get :roles_settings
        delete :destroy_bulk
      end
    end

    resources :email_templates

    resources :payment_terms

    resources :accounts
    resources :help

    resources :reports, only: [] do
      collection do
        get :invoice_detail
        get :aged_accounts_receivable
        get :item_sales
        get :payments_collected
        get :revenue_by_client
      end
    end
    resources :activities do
      collection do
        post :read_notifications
      end
    end
    get "reports/:report_name" => "reports#reports"
    get "reports/data/:report_name" => "reports#payments_collected"
    get "reports" => "reports#index"

    get "dashboard" => "dashboard#index"
    post 'dashboard/chart_details' => "dashboard#chart_details"
    post '/invoices/send_note_only' => 'invoices#send_note_only'
    resources :payments do
      collection do
        get 'enter_payment'
        get 'refund_payment'
        put 'update_individual_payment'
        get 'filter_payments'
        get 'bulk_actions'
        get 'undo_actions'
        get 'payments_history'
        get 'invoice_payments_history'
        post 'delete_non_credit_payments'
      end
    end
    resources :taxes do
      collection do
        get 'filter_taxes'
        get 'bulk_actions'
        get 'undo_actions'
      end
    end

    get "invoices/unpaid_invoices" => "invoices#unpaid_invoices"
    post '/payments/enter_payment'
    resources :clients do
      collection do
        post :client_detail
        get 'filter_clients'
        get 'bulk_actions'
        post 'get_last_invoice'
        post 'get_last_estimate'
        get 'undo_actions'
      end
      member do
        post :create_password
        get 'default_currency'
      end
    end
    get "clients/:id/joinOSB" => 'clients#new_password', as: 'new_password_client'


    resources :client_contacts


    devise_for :users
    #, controllers: {sessions: "devise/sessions", registrations: "devise/registrations", passwords: "devise/passwords"}
    scope module: 'portal/client', path: 'portal/client', as: 'portal' do
      #,  controllers: {sessions: "portal/clients/sessions", registrations: "portal/clients/registrations", passwords: "portal/clients/passwords"}
      resources :invoices do
        member do
          get :invoice_receipt
        end
      end
      resources :estimates
      resources :payments
      resources :settings
      #get "client/dashboard" => "dashboard#index"
      resources :dashboard, only: :index
    end

    scope path: 'portal', as: 'portal' do
      devise_for :clients
    end

    devise_scope :user do
      root :to => "devise/sessions#new"
    end

    #resources :categories


    resources :items do
      collection do
        get 'filter_items'
        get 'bulk_actions'
        post 'load_item_data'
        get 'duplicate_item'
        get 'undo_actions'
      end
    end

    resources :expenses do
      collection do
        get 'bulk_actions'
        get 'filter_items'
        get 'undo_actions'
      end
    end

    resources :invoice_line_items

    resources :invoices do
      resources :invoice_line_items
      collection do
        get 'filter_invoices'
        get 'bulk_actions'
        get 'undo_actions'
        post 'duplicate_invoice'
        get 'enter_single_payment'
        get 'send_invoice'
        post 'paypal_payments'
        get  'paypal_payments'
        post 'preview'
        get 'preview'
        get 'credit_card_info'
        get 'selected_currency'
        get :set_client_currency
        get 'void_invoice'
      end
      member do
        get 'stop_recurring'
        get 'clone'
      end
    end

    resources :projects do
      collection do
        get 'bulk_actions'
        get 'undo_actions'
      end
      resources :project_tasks
    end

    post '/invoices/delete_invoices_with_payments' => 'invoices#delete_invoices_with_payments'
    post '/invoices/dispute_invoice' => 'invoices#dispute_invoice'
    post '/invoices/pay_with_credit_card' => 'invoices#pay_with_credit_card'
    post '/invoices/payment_with_credit_card' => 'invoices#payment_with_credit_card'

    resources :recurring_profile_line_items

    resources :sent_emails
    #get 'oauth/applications' => ''

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
    resources :recurring_profiles do
      resources :recurring_profile_line_items
      collection do
        get 'filter_recurring_profiles'
        get 'bulk_actions'
        get 'undo_actions'
        get 'selected_currency'
      end
    end
    resources :company_profiles


    resources :client_additional_contacts


    resources :sent_emails
    resources :estimates do
      collection do
        get 'selected_currency'
        get 'send_estimate'
        get 'bulk_actions'
        get 'undo_actions'
        get 'preview'
        get :set_client_currency
      end
      member do
        get 'convert_to_invoice'
      end
    end

    #get 'calendar' => 'calendar#index'
    #get 'calendar' => 'log#index'
    resources :logs do
      collection do
        get 'events'
        get 'update_tasks', as: 'update_tasks'
        get 'load_view'
        get 'timer'
        get 'invoice'
        #post 'invoice_form'
        post 'create_invoice'
      end
      member do
        get 'invoice_form'
      end
    end


    resources :import_data do
      collection do
        post 'import_freshbooks_data', as: 'import_freshbooks_data'
        post 'import_quickbooks_data', as: 'import_quickbooks_data'
        get 'select_qb_data', as: 'select_qb_data'
        get :authenticate
        get :oauth_callback
      end

    end
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
    #root :to => 'dashboard#index'

    # See how all your routes lay out with "rake routes"

    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.

    get ':controller(/:action(/:id))(.:format)'
  end  
end
