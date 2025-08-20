module FactorySeeder
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    layout 'factory_seeder/application'
  end
end
