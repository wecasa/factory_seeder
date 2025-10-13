# frozen_string_literal: true

module FactorySeeder
  class Seed
    attr_reader :name, :description, :parameters, :block, :metadata

    def initialize(name, description: nil, parameters: {}, metadata: {}, &block)
      @name = name.to_sym
      @description = description || "Seed for #{name}"
      @parameters = parameters.transform_keys(&:to_sym)
      @metadata = metadata.transform_keys(&:to_sym)
      @block = block
      @created_at = Time.now
    end

    def call(**kwargs)
      validate_parameters!(kwargs)
      @block.call(**kwargs)
    end

    def parameter_names
      @parameters.keys
    end

    def has_parameters?
      @parameters.any?
    end

    def parameter_info(name)
      @parameters[name.to_sym]
    end

    def validate_parameters!(kwargs)
      # Check for required parameters
      required_params = @parameters.select { |_, info| info[:required] }.keys
      missing_params = required_params - kwargs.keys

      raise ArgumentError, "Missing required parameters: #{missing_params.join(', ')}" if missing_params.any?

      # Validate parameter types and values
      kwargs.each do |key, value|
        param_info = @parameters[key]
        next unless param_info

        validate_parameter_type!(key, value, param_info)
        validate_parameter_value!(key, value, param_info)
      end
    end

    def to_h
      {
        name: @name,
        description: @description,
        parameters: @parameters,
        metadata: @metadata,
        created_at: @created_at,
        has_parameters: has_parameters?
      }
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    private

    def validate_parameter_type!(key, value, param_info)
      expected_type = param_info[:type]
      return unless expected_type

      case expected_type
      when :string
        raise ArgumentError, "Parameter '#{key}' must be a string" unless value.is_a?(String)
      when :integer
        raise ArgumentError, "Parameter '#{key}' must be an integer" unless value.is_a?(Integer)
      when :boolean
        raise ArgumentError, "Parameter '#{key}' must be a boolean" unless [true, false].include?(value)
      when :symbol
        raise ArgumentError, "Parameter '#{key}' must be a symbol" unless value.is_a?(Symbol)
      when :array
        raise ArgumentError, "Parameter '#{key}' must be an array" unless value.is_a?(Array)
      end
    end

    def validate_parameter_value!(key, value, param_info)
      # Check allowed values
      if param_info[:allowed_values] && !param_info[:allowed_values].include?(value)
        raise ArgumentError, "Parameter '#{key}' must be one of: #{param_info[:allowed_values].join(', ')}"
      end

      # Check min/max for numeric values
      if param_info[:min] && value < param_info[:min]
        raise ArgumentError, "Parameter '#{key}' must be >= #{param_info[:min]}"
      end

      return unless param_info[:max] && value > param_info[:max]

      raise ArgumentError, "Parameter '#{key}' must be <= #{param_info[:max]}"
    end
  end
end
