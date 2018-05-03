Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'projects#index'

  get '/ui' => 'pages#ui'
  post '/tools/detect-bias' => 'tools#detect_bias'

  devise_for :users,
            path_names: { 
              sign_up: 'register', 
              sign_in: 'login', 
              sign_out: 'logout' 
            },
            controllers: { registrations: 'users', sessions: 'sessions' }

  resources :projects do
    get :pads
    get :checklist_report

    resources :collaborators, only: [:index, :destroy] do
      post :invite, on: :collection
      get :suggest, on: :collection
      put :promote, on: :member
    end

    resources :checklists, only: [:index] do
      put :check, on: :collection
    end

    resources :project_pads, only: [:new, :create, :edit, :update, :destroy]
    resources :queries
    resources :meme_mappers
  end
end
