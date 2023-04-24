Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "matches#index"

  resources :matches
  resources :match_stats
  resources :accounts, only: [:show]
  get "/accounts/:id/matches/load", to: "accounts#load_matches", as: "load_matches"
  get "/accounts/:id/matches/update", to: "accounts#update_matches", as: "update_matches"
  get "/global/update", to: "accounts#global_update", as: "global_update"
  get "/heroes", to: "heroes#index"
  get "/heroes/load", to: "heroes#load"
  # get "/accounts/:id", to: "accounts#index"
  # get "heroes/update", to: "heroes#update"
  # get "/matches", to: "matches#index"
  # get "/matches/:id", to: "matches#show"
end
