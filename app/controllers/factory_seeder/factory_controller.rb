module FactorySeeder
  class FactoryController < ApplicationController

    def index
      @factories = FactorySeeder.scan_loaded_factories
    end

    def show
      @factory_name = params[:name]
      @factories = FactorySeeder.scan_loaded_factories
      @factory = @factories[@factory_name]

      return if @factory

      redirect_to root_path, alert: "Factory '#{@factory_name}' not found"
      nil
    end

    def generate
      factory_name = params[:name]
      count = (params[:count] || 1).to_i
      traits = parse_traits(params[:traits])

      begin
        generator = SeedGenerator.new
        result = generator.generate(factory_name, count, traits, generate_params[:attributes].to_h.compact_blank)

        if result[:errors].any?
          flash[:error] = "Error generating seeds: #{result[:errors].join(', ')}"
          redirect_to factory_path(factory_name)
        else
          flash[:success] = "Successfully generated #{result[:count]} #{factory_name} records!"
          redirect_to factory_path(factory_name)
        end
      rescue StandardError => e
        flash[:error] = "Error generating seeds: #{e.message}"
        redirect_to factory_path(factory_name)
      end
    end

    def preview
      factory_name = params[:name]
      count = (params[:count] || 1).to_i
      traits = parse_traits(params[:traits])
      attributes = generate_params[:attributes]

      begin
        generator = SeedGenerator.new
        @preview_data = generator.preview(factory_name, count, traits, attributes)
        @factory_name = factory_name

        render :preview
      rescue StandardError => e
        flash[:error] = "Error previewing factory: #{e.message}"
        redirect_to factory_path(factory_name)
      end
    end

    private

    def parse_traits(traits_param)
      return [] if traits_param.blank?

      if traits_param.is_a?(String)
        traits_param.split(',').map(&:strip).reject(&:blank?)
      else
        traits_param
      end
    end

    def generate_params
      params.permit(:name, :count, :traits, attributes: {})
    end
  end
end
