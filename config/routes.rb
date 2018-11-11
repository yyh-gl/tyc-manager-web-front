Rails.application.routes.draw do
  devise_for :users

  root 'transactions#index'
  get 'transactions/show'
  get 'transactions/create'
end
