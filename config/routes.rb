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
    get 'requests/pickup' => 'requests#index_pick_up'
    post 'users/:user_id/requests' => 'requests#create'
    put 'users/:user_id/requests/:id/car_pick_up' => 'requests#car_pick_up'
    patch 'users/:user_id/requests/:id/car_pick_up' => 'requests#car_pick_up'
    put 'users/:user_id/requests/:id/request_drop_off' => 'requests#request_drop_off'
    patch 'users/:user_id/requests/:id/request_drop_off' => 'requests#request_drop_off'
    
    put 'valets/:valet_id/requests/:id/valet_pick_up' => 'requests#valet_pick_up'
    patch 'valets/:valet_id/requests/:id/valet_pick_up' => 'requests#valet_pick_up'
    put 'valets/:valet_id/requests/:id/car_parked' => 'requests#car_parked'
    patch 'valets/:valet_id/requests/:id/car_parked' => 'requests#car_parked'
    put 'valets/:valet_id/requests/:id/valet_drop_off' => 'requests#valet_drop_off'
    patch 'valets/:valet_id/requests/:id/valet_drop_off' => 'requests#valet_drop_off'
    put 'valets/:valet_id/requests/:id/valet_delivery' => 'requests#valet_delivery'
    patch 'valets/:valet_id/requests/:id/valet_delivery' => 'requests#valet_delivery'




  end  
end
