Rails.application.routes.draw do
  get 'transactions/create'
  devise_for :users

  devise_scope :user do
    root 'devise/sessions#new'
  end

  resources :transactions, only: [:index, :create]
  resources :forms, only: [:index, :create]

  # deviseのコントローラいじるのがめんどかったのでtransactionsコントローラにパスワード忘れたときようの処理を追加
  get '/users/password/forget', to: 'transactions#forget'
end
