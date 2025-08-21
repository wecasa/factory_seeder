module FactorySeeder
  class ApiController < ApplicationController
    def factories
      factories = FactorySeeder.scan_loaded_factories
      render json: factories
    end

    def factory_preview
      factory_name = params[:name]
      attributes = parse_attributes(params[:attributes])

      begin
        generator = SeedGenerator.new
        preview = generator.preview(factory_name, attributes)
        render json: { success: true, preview: preview }
      rescue StandardError => e
        render json: { success: false, error: e.message }, status: :unprocessable_entity
      end
    end

    private

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
