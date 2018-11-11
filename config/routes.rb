Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    root 'devise/sessions#new'
  end

  get '/transactions', to: 'transactions#index'
end
