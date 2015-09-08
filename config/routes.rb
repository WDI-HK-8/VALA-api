Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  mount_devise_token_auth_for 'Valet', at: 'valets'
  as :valet do
    # Define routes for Valet within this block.


  end
  root 'static_pages#index'

    # valet change profile info
    patch '/api/v1/valets/:id' => 'valets#update'

    #show all valets available
    get '/api/v1/valets/available' => 'valets#available'
    
    #show one valet
    get '/api/v1/valets/:id' => 'valets#show'

    #show all valets
    get '/api/v1/valets' => 'valets#index'


  
end
