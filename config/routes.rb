Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "matches#index"

  resources :matches
  get "/heroes", to: "heroes#index"
  get "/heroes/load", to: "heroes#load"
  # get "heroes/update", to: "heroes#update"
  # get "/matches", to: "matches#index"
  # get "/matches/:id", to: "matches#show"
end
