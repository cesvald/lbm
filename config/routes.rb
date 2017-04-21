# -*- encoding : utf-8 -*-
require 'sidekiq/web'

Catarse::Application.routes.draw do


  match '/thank_you' => "static#thank_you"
  match '/email' => "static#email"

  devise_for :users, path: '', 
    path_names:   { sign_in: :login, sign_out: :logout, sign_up: :register }, 
    controllers:  { omniauth_callbacks: :omniauth_callbacks, sessions: :sessions, registrations: :registrations }

  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  filter :locale, exclude: /\/auth\//

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount CatarsePaypalExpress::Engine => "/", as: :catarse_paypal_express
  mount CatarsePayulatam::Engine => "/", :as => :catarse_payulatam
  #mount CatarseMercadopago::Engine => "/", :as => :catarse_mercadopago
  mount CatarseLbmGiftCards::Engine => "/", :as => :catarse_lbm_gift_cards
  # mount CatarsePayroll::Engine => "/", :as => :catarse_payroll
  
  post '/mercadopago/notification', to: 'mercadopago#notification', as: :mercadopago_notification
  get '/mercadopago/notification', to: 'mercadopago#notification', as: :mercadopago_notification
  get 'mercadopago/success', to: 'mercadopago#success', as: :mercadopago_success
  get 'mercadopago/failure', to: 'mercadopago#failure', as: :mercadopago_failure
  
  # Non production routes
  if Rails.env.development?
    resources :emails, only: [ :index ]
  end

  # Channels
  constraints subdomain: /^(?!lbm3-cesvald|www|secure|test|local)(\w+)/ do
    namespace :channels, path: '' do
      namespace :adm do
        resources :projects, only: [ :index, :update] do
          member do
            put 'approve'
            put 'reject'
            put 'push_to_draft'
          end
        end
        resources :iniciatives
      end
      get '/', to: 'profiles#show', as: :profile
      get '/how-it-works', to: 'profiles#how_it_works', as: :about
      resources :projects, only: [:new, :create, :show] do
        collection do
          get 'video'
          get 'check_slug'
        end
        member do
          post 'finance'
        end
      end
      resources :channels_subscribers, only: [:index, :create, :destroy]
      resources :phases
      resources :iniciatives
      resources :financial_channels, only: :index do
        member do
          put 'close_summoning'
          put 'close_applaying'
          put 'announce'
        end
      end
    end
  end

  match "/credits" => "credits#index", as: :credits

  match "/reward/:id" => "rewards#show", as: :reward
  resources :posts, only: [:index, :create]

  namespace :reports do
    resources :backer_reports_for_project_owners, only: [:index]
  end

  match "/explore" => "explore#index", as: :explore
  match "/explore#:quick" => "explore#index", as: :explore_quick
  
  # Static Pages
  get '/sitemap',               to: 'static#sitemap',             as: :sitemap
  get "/about",                 to: "static#about",               as: :about
  get '/guidelines',            to: 'static#guidelines',          as: :guidelines
  get "/guidelines_tips",       to: "static#guidelines_tips",     as: :guidelines_tips
  get "/guidelines_backers",    to: "static#guidelines_backers",  as: :guidelines_backers
  get "/guidelines_start",      to: "static#guidelines_start",    as: :guidelines_start
  get "/guidelines_channels",   to: "static#guidelines_channel",  as: :guidelines_channels
  get "/tools",                 to: "static#tools",               as: :tools
  
  
  resources :projects do
    resources :updates, only: [ :index, :create, :destroy ]
    resources :pictures, only: [ :index, :create, :destroy ]
    resources :rewards, only: [ :index, :create, :update, :destroy ] do
      member do
        post 'sort'
      end
    end
    resources :backers, controller: 'projects/backers', only: [ :index, :show, :new, :create ] do
      member do
        match 'credits_checkout'
        post 'update_info'
      end
    end
    collection do
      get 'video'
      get 'check_slug'
    end
    member do
      put 'pay'
      get 'embed'
      get 'video_embed'
      get 'documents'
    end
  end
  
  resources :users, except: [:index, :new, :create, :edit, :destroy] do
    collection do
      get :uservoice_gadget
      get :contact_and_support
      post :authenticate_user
      get :change_user
    end
    resources :backers, only: [:index] do
      member do
        match :request_refund
      end
      collection do
        get :certificate_request
        post :confirm_certificate_request
      end
    end

    resources :unsubscribes, only: [:create]
    member do
      get 'projects'
      get 'credits'
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password'
    end
  end
  # match "/users/:id/request_refund/:back_id" => 'users#request_refund'

  resources :credits, only: [:index] do
    collection do
      get 'buy'
      post 'refund'
    end
  end

  namespace :adm do
    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
        put 'finish'
        get 'show_review'
        put 'review'
        get 'test'
      end
    end

    resources :statistics, only: [ :index ]
    resources :financials, only: [ :index ]

    resources :backers, only: [ :index, :update ] do
      member do
        put 'confirm'
        put 'pendent'
        put 'change_reward'
        put 'refund'
        put 'hide'
        put 'cancel'
        put 'push_to_trash'
      end
    end
    resources :users, only: [ :index ]
    resources :iniciatives do
      member do
        put 'approve'
      end
    end
    resources :channels, except: [ :show ] do
      resources :projects, controller: 'channels/projects', only: [:create, :destroy], on: :member
      resources :trustees, controller: 'channels/trustees', only: [:create, :destroy], on: :member
    end

    namespace :reports do
      resources :backer_reports, only: [ :index ]
    end
  end

  match "/mudancadelogin" => "users#set_email", as: :set_email_users
  match "/:permalink" => "projects#show", as: :project_by_slug

  # Root path
  root to: 'projects#index'

end
