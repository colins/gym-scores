Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :gymnasts, only: [:index, :show]
      resources :competitions, only: [:index, :show]

      get "search", to: "scraper#search"
      post "scrape", to: "scraper#create"
      post "gymnasts/:id/refresh", to: "scraper#refresh", as: :refresh_gymnast
      post "gymnasts/:id/link_mso", to: "scraper#link_mso", as: :link_mso_gymnast
      patch "scores/:score_id", to: "scraper#update_score", as: :update_score
      delete "scores/:score_id", to: "scraper#delete_score", as: :delete_score
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
