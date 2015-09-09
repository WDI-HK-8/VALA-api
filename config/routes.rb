Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  mount_devise_token_auth_for 'Valet', at: 'valets'
  as :valet do
    # Define routes for Valet within this block.
  end
  root 'static_pages#index'
  resources 'requests', :path => 'api/v1/requests'
end
