source 'https://rubygems.org'
ruby '2.2.2'

gem 'rails', '4.2.3'
gem 'uglifier', '>= 1.3.0'
gem 'pg'
gem 'bower'
gem 'devise_token_auth'
gem 'active_hash'
gem 'rails_12factor', group: :production
gem 'omniauth'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'dotenv-rails'
gem 'rack-cors', :require => 'rack/cors'
gem 'aasm'
gem 'geocoder'
#the regular private pub would not work.  Had to create own version of it and push it to ruby gems
#due to validation of time stamp and sig.
gem 'private_pub_no_sig'
gem "thin"

group :development, :test do
  gem 'byebug'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'web-console', '~> 2.0'
  gem 'spring'
end
  