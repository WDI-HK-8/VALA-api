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
    post 'users/:user_id/requests' => 'requests#create'
    put 'valets/:valet_id/requests/:id/valet_pick_up' => 'requests#valet_pick_up'

    patch 'valets/:valet_id/requests/:id/valet_pick_up' => 'requests#valet_pick_up'

    get 'requests/pickup' => 'requests#index_pick_up'
  end  
end
