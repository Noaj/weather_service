Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # We set our HOME page as teh index page. Where the user will input an address
  root "weather_forecasts#index"

  # We send the address to this endpoint to validate and return the weather response
  post '/weather_forecasts', to: 'weather_forecasts#weather_by_zipcode'
  get '/weather_forecasts', to: 'weather_forecasts#index'
end
