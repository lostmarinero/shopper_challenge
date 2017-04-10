Rails.application.routes.draw do
  resources :applicants, only: [:create, :update, :show, :new]
  resources :funnels, only: [:index]
  root to: 'welcome#index'
end
