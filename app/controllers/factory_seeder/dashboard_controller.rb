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

    def preview_factory
      factory_name = params[:name]
      count = (params[:count] || 1).to_i
      traits = parse_traits(params[:traits])
      attributes = parse_attributes(params[:attributes])

      begin
        generator = SeedGenerator.new
        @preview_data = generator.preview(factory_name, count, traits, attributes)
        @factory_name = factory_name

        render :preview_factory
      rescue StandardError => e
        flash[:error] = "Error previewing factory: #{e.message}"
        redirect_to root_path
      end
    end

    private

    def get_seeds_info
      FactorySeeder.list_seeds.keys
    end

    def parse_traits(traits_param)
      return [] if traits_param.blank?

      if traits_param.is_a?(String)
        traits_param.split(',').map(&:strip).reject(&:blank?)
      else
        traits_param
      end
    end

    def parse_attributes(attributes_param)
      return {} if attributes_param.blank?

      if attributes_param.is_a?(String)
        begin
          JSON.parse(attributes_param)
        rescue JSON::ParserError
          {}
        end
      else
        attributes_param
      end
    end
  end
end
