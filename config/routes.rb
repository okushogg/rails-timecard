Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/' => 'webhook#index'
  post '/punch_in' => 'webhook#punch_in'
  post '/punch_out' => 'webhook#punch_out'
  post '/callback' => 'webhook#callback'
end
