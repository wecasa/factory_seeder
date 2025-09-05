# frozen_string_literal: true

module FactorySeeder
  class CustomSeedsController < ApplicationController
    def index
      @seeds = FactorySeeder.list_seeds
    end

    def show
      seed = FactorySeeder.list_seeds.find { |key, block| key.to_s == params[:name] }
      @seed_name = seed[0]
      @seed = seed[1]
    end

    def create
      begin
        seed_name = params[:name]&.to_sym
        attributes = {country: :fr, universe: :cleaning}

        result = FactorySeeder.seeder.run(seed_name, **attributes)
      rescue StandardError => e
        flash[:error] = "Seed #{params[:name]} not found: #{e.message}"
        redirect_to custom_seed_path(params[:name])
      else
        flash[:success] = "Seed #{params[:name]} generated successfully"
        redirect_to custom_seed_path(params[:name])
      end
    end

    private

    def safe_attributes_params
      if params.key?(:attributes)
        params.require(:attributes).permit!.transform_keys(&:to_sym).transform_values(&:to_sym).compact_blank
      else
        {}
      end
    end
  end
end