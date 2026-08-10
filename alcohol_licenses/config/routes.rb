Rails.application.routes.draw do
  root 'maps#index'

  get 'map', to: 'maps#index'
  get 'map/licenses', to: 'maps#licenses'
  get 'map/raw_records', to: 'maps#raw_records'
  get 'map/statistics', to: 'maps#statistics'
  get 'map/statistics_static', to: 'maps#statistics_static'
  get 'geocoding_reviews', to: 'geocoding_reviews#index'
  get 'geocoding_reviews/categories', to: 'geocoding_reviews#categories'
  get 'geocoding_reviews/next', to: 'geocoding_reviews#next'
  post 'geocoding_reviews/:transformed_location_id', to: 'geocoding_reviews#create', as: :geocoding_review
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
