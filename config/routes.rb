Rails.application.routes.draw do
  resources :applicants, only: [
    :create, :update, :show, :new, :edit
  ]
  resources :funnels, only: [:index]
  root to: 'welcome#index'

  get 'login', to: 'applicants#login'
  post 'login', to: 'applicants#create_session'
  get 'logout', to: 'applicants#end_session'
end
