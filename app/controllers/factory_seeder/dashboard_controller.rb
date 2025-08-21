module FactorySeeder
  class DashboardController < ApplicationController
    def index
      @factories = FactorySeeder.scan_loaded_factories
    end
  end
end
