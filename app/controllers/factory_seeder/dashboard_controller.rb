# frozen_string_literal: true

module FactorySeeder
  class DashboardController < ApplicationController
    def index
      @factories = FactorySeeder.scan_loaded_factories
      @seeds_info = FactorySeeder.list_seeds
    end

    def run_seed
      params[:name]

      begin
        flash[:info] = 'Seed system coming soon! For now, use the factory generation interface.'
        redirect_to root_path
      rescue StandardError => e
        flash[:error] = "Error running seed: #{e.message}"
        redirect_to root_path
      end
    end

    def run_all_seeds
      flash[:info] = 'Seed system coming soon! For now, use the factory generation interface.'
      redirect_to root_path
    rescue StandardError => e
      flash[:error] = "Error running seeds: #{e.message}"
      redirect_to root_path
    end

    private

    def get_seeds_info
      FactorySeeder.list_seeds.keys
    end
  end
end
