# frozen_string_literal: true

FactorySeeder::Engine.routes.draw do
  # Main dashboard
  root 'dashboard#index'

  # Factory details and generation
  get '/factory/:name', to: 'factory#show', as: :factory
  get '/factory', to: 'factory#index', as: :factory_index
  post '/factory/:name/generate', to: 'factory#generate', as: :generate_factory

  # Custom seeds
  get '/custom_seeds', to: 'custom_seeds#index', as: :custom_seeds
  get '/custom_seeds/:name', to: 'custom_seeds#show', as: :custom_seed
  post '/custom_seeds/:name/generate', to: 'custom_seeds#create', as: :create_custom_seede
end
