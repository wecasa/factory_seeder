# frozen_string_literal: true

module FactorySeeder
  class CustomSeedsController < ApplicationController
    def index
      @seeds = FactorySeeder.list_custom_seeds
    end

    def show
      @seed = FactorySeeder.find_custom_seed(params[:name])
      if @seed.nil?
        flash[:error] = "Seed '#{params[:name]}' not found"
        redirect_to custom_seeds_path
        return
      end
      @seed_name = @seed.name
      @execution_logs = []
    end

    def create
      @seed_name = params[:name]
      @seed = FactorySeeder.find_custom_seed(@seed_name)

      if @seed.nil?
        flash[:error] = "Seed '#{@seed_name}' not found"
        redirect_to custom_seeds_path
        return
      end

      attributes = safe_attributes_params
      result = FactorySeeder.run_custom_seed(@seed_name, **attributes)
      @execution_logs = result[:logs] || []

      if result[:success]
        flash.now[:success] = result[:message]
      else
        flash.now[:error] = result[:message]
      end

      render :show
    end

    def new
      # For creating new seeds via web interface (future feature)
      @seed = nil
    end

    def edit
      @seed = FactorySeeder.find_custom_seed(params[:name])
      return unless @seed.nil?

      flash[:error] = "Seed '#{params[:name]}' not found"
      redirect_to custom_seeds_path
      nil
    end

    def update
      # For updating existing seeds (future feature)
      seed_name = params[:name]
      # Implementation would go here
      redirect_to custom_seed_path(seed_name)
    end

    def destroy
      # For deleting seeds (future feature)
      params[:name]
      # Implementation would go here
      redirect_to custom_seeds_path
    end

    private

    def safe_attributes_params
      if params.key?(:attributes)
        # Convert string values to appropriate types based on seed parameter definitions
        raw_attributes = params.require(:attributes).permit!
        seed = FactorySeeder.find_custom_seed(params[:name])

        if seed
          convert_attributes_to_types(raw_attributes, seed)
        else
          raw_attributes.transform_keys(&:to_sym)
        end
      else
        {}
      end
    end

    def convert_attributes_to_types(raw_attributes, seed)
      converted = {}

      raw_attributes.each do |key, value|
        param_info = seed.parameter_info(key)
        converted[key.to_sym] = convert_value_to_type(value, param_info)
      end

      converted
    end

    def convert_value_to_type(value, param_info)
      return value if value.blank?

      case param_info&.dig(:type)
      when :integer
        value.to_i
      when :boolean
        case value.to_s.downcase
        when 'true', '1', 'yes', 'on'
          true
        when 'false', '0', 'no', 'off'
          false
        else
          value
        end
      when :symbol
        value.to_sym
      when :array
        if value.is_a?(String)
          value.split(',').map(&:strip)
        else
          value
        end
      else
        value
      end
    end
  end
end
