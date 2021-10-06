Rails.application.routes.draw do
  namespace :api do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      registrations: 'api/auth/registrations'
    }
    #だれでも見れる全表示を実装予定（SNS風に）
    # get '/holdings' => 'holdings#xxxindex'
    # get '/holdings/:id' => 'holdings#xxxshow'
    resources :users do
      resources :holdings
    end
    get '/stocks' => 'stocks#index'
    get '/stocks/:id' => 'stocks#show'

  end
end
