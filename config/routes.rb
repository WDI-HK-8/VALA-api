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
        put ':valet_id/requests/:id/valet_pick_up' => 'requests#valet_pick_up'
        patch ':valet_id/requests/:id/valet_pick_up' => 'requests#valet_pick_up'
        put ':valet_id/requests/:id/car_parked' => 'requests#car_parked'
        patch ':valet_id/requests/:id/car_parked' => 'requests#car_parked'
        put ':valet_id/requests/:id/valet_drop_off' => 'requests#valet_drop_off'
        patch ':valet_id/requests/:id/valet_drop_off' => 'requests#valet_drop_off'
        put ':valet_id/requests/:id/valet_delivery' => 'requests#valet_delivery'
        patch ':valet_id/requests/:id/valet_delivery' => 'requests#valet_delivery'
      end
    end

    scope 'users/:user_id/requests' do
      post '/' => 'requests#create'
      put ':id/car_pick_up' => 'requests#car_pick_up'
      patch ':id/car_pick_up' => 'requests#car_pick_up'
      put ':id/request_drop_off' => 'requests#request_drop_off'
      patch ':id/request_drop_off' => 'requests#request_drop_off'
      put ':id/car_drop_off' => 'requests#car_drop_off'
      patch ':id/car_drop_off' => 'requests#car_drop_off'
      put ':id/ratings' => 'requests#ratings'
      patch ':id/ratings' => 'requests#ratings'
    end

    scope 'requests/' do
      get 'pickup' => 'requests#index_pick_up'
      put ':id/cancel_request' => 'requests#cancel_request'
      patch ':id/cancel_request' => 'requests#cancel_request'
    end
    
  end  
end
