Rails.application.routes.draw do

  root 'welcome#index'
  post '/account_registration_step2', to: 'welcome#account_registration_step2', as: 'account_registration_step2'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  get 'user/profile', to: 'users#profile', as: 'profile'
  match 'user/bitshares_account', to: 'users#bitshares_account', as: 'bitshares_account', via: [:get, :post]

  devise_scope :user do
    get 'sign_out', to: 'devise/sessions#destroy', :as => :sign_out
  end

  namespace :admin do
    resources :referral_codes
  end

  namespace :api do
    namespace :v1 do
      resources :referral_codes do
        get 'redeem'
      end
    end
  end

end
