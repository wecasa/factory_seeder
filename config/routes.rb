# frozen_string_literal: true

FactorySeeder::Engine.routes.draw do
  # Dashboard principal
  root 'dashboard#index'

  # Factory details et génération
  get '/factory/:name', to: 'factory#show', as: :factory
  post '/generate', to: 'factory#generate', as: :generate

  # API endpoints
  get '/api/factories', to: 'api#factories', as: :api_factories
  get '/api/factory/:name/preview', to: 'api#factory_preview', as: :api_factory_preview
end
