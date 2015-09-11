Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  mount_devise_token_auth_for 'Valet', at: 'valets'
  as :valet do
    # Define routes for Valet within this block.
  end

  root 'static_pages#index'

  scope '/api/v1' do
    resources :valets, only: [:update, :show, :index] do
      resources :requests, only: :update do
        put 'valet_pick_up'
        patch 'valet_pick_up'
        put 'car_parked'
        patch 'car_parked'
        put 'valet_drop_off'
        patch 'valet_drop_off'
        put 'valet_delivery'
        patch 'valet_delivery'
      end
      collection do
        get 'available' 
      end
    end

    resources :users, only: :update do
      resources :requests, only: [:update, :create] do
        put 'car_pick_up'
        patch 'car_pick_up'
        put 'request_drop_off'
        patch 'request_drop_off'
        put 'car_drop_off'
        patch 'car_drop_off'
        put 'ratings'
        patch 'ratings'
      end
    end

    scope 'requests/' do
      get 'pickup' => 'requests#index_pick_up'
      put ':id/cancel_request' => 'requests#cancel_request'
      patch ':id/cancel_request' => 'requests#cancel_request'
    end
    
  end  
end
