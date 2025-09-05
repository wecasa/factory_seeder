# frozen_string_literal: true

FactorySeeder::Engine.routes.draw do
  # Dashboard principal
  root 'dashboard#index'

  # Factory details et génération
  get '/factory/:name', to: 'factory#show', as: :factory
  get '/factory', to: 'factory#index', as: :factory_index
  post '/factory/:name/generate', to: 'factory#generate', as: :generate_factory
  get '/factory/:name/preview', to: 'factory#preview', as: :preview_factory

  # Seeds actions
  post '/seeds/:name', to: 'dashboard#run_seed', as: :run_seed
  post '/seeds', to: 'dashboard#run_all_seeds', as: :run_all_seeds

  # Custom seeds
  get '/custom_seeds', to: 'custom_seeds#index', as: :custom_seeds
  get '/custom_seeds/:name', to: 'custom_seeds#show', as: :custom_seed
  post '/custom_seeds/:name/generate', to: 'custom_seeds#create', as: :create_custom_seede

  # Factory preview depuis dashboard
  get '/preview/:name', to: 'dashboard#preview_factory', as: :preview_factory_from_dashboard
end
