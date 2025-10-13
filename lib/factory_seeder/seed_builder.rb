# frozen_string_literal: true

module FactorySeeder
  class SeedBuilder
    def initialize(name)
      @name = name
      @description = nil
      @parameters = {}
      @metadata = {}
    end

    def description(text)
      @description = text
      self
    end

    def parameter(name, type: :string, required: false, default: nil, allowed_values: nil, min: nil, max: nil,
                  description: nil)
      # Validation des paramètres selon le type
      validate_parameter_options(type, allowed_values: allowed_values, min: min, max: max)

      @parameters[name.to_sym] = {
        type: type,
        required: required,
        default: default,
        allowed_values: allowed_values,
        min: min,
        max: max,
        description: description
      }
      self
    end

    def metadata(key, value)
      @metadata[key.to_sym] = value
      self
    end

    def build(&block)
      Seed.new(
        @name,
        description: @description,
        parameters: @parameters,
        metadata: @metadata,
        &block
      )
    end

    private

    def validate_parameter_options(type, allowed_values:, min:, max:)
      case type
      when :integer
        raise ArgumentError, 'allowed_values is not valid for integer type' if allowed_values
      when :string, :symbol
        raise ArgumentError, "min and max are not valid for #{type} type" if min || max
      when :boolean
        if min || max || allowed_values
          raise ArgumentError,
                'min, max, and allowed_values are not valid for boolean type'
        end
      when :array
        raise ArgumentError, 'min, max, and allowed_values are not valid for array type' if min || max || allowed_values
      end
    end
  end
end
