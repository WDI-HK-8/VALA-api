Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  mount_devise_token_auth_for 'Valet', at: 'valets'
  as :valet do
    # Define routes for Valet within this block.
  end

  root 'static_pages#index'

  scope '/api/v1' do
    resources :valets, only: [:update, :show, :index] do
      collection do
        get 'available'
      end
    end
    resources :users
  end  
  resources 'requests', :path => 'api/v1/requests'
  post 'api/v1/users/:user_id/requests' => 'requests#create'

  resources 'requests', :path => 'api/v1/requests'
  post 'api/v1/users/:user_id/requests' => 'requests#create'
  put 'api/v1/valets/:valet_id/requests/:id/valet_pick_up' => 'requests#valet_pick_up'

  patch 'api/v1/valets/:valet_id/requests/:id/valet_pick_up' => 'requests#valet_pick_up'

  get 'api/v1/requests/pickup' => 'requests#index_pick_up'
end
