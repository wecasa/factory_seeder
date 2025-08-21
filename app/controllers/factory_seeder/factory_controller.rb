module FactorySeeder
  class FactoryController < ApplicationController
    def show
      @factory_name = params[:name]
      @factories = FactorySeeder.scan_loaded_factories
      @factory = @factories[@factory_name]

      return if @factory

      redirect_to root_path, alert: "Factory '#{@factory_name}' not found"
      nil
    end

    def generate
      factory_name = params[:factory_name]
      count = (params[:count] || 1).to_i
      traits = parse_traits(params[:traits])
      attributes = parse_attributes(params[:attributes])

      begin
        generator = SeedGenerator.new
        result = generator.generate(factory_name, count, traits, attributes)

        render json: { success: true, result: result }
      rescue StandardError => e
        render json: { success: false, error: e.message }, status: :unprocessable_entity
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
