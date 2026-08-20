# frozen_string_literal: true

module FactorySeeder
  class DashboardController < ApplicationController
    def index
      @factories = FactorySeeder.scan_loaded_factories
      @seeds = FactorySeeder.list_custom_seeds
    end
  end
end
