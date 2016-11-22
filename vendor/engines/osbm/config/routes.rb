Osbm::Engine.routes.draw do
  get '/home' => 'dashboard#home'
  post '/landing' => 'dashboard#landing'
  resource :admin, only: [] do
    get 'accounts'
    get 'new_account'
    get 'users'
    get 'plans'
    post 'create_account'
  end
end
