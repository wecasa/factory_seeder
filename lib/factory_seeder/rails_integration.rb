# frozen_string_literal: true

module FactorySeeder
  module RailsIntegration
    def self.setup
      return unless defined?(Rails)

      # Force eager loading when Rails hasn't done it (development/test with lazy loading)
      if Rails.respond_to?(:application) && Rails.application && !Rails.application.config.eager_load
        Rails.application.eager_load!
      end

      # Add Rails-specific factory paths
      FactorySeeder.configuration.factory_paths << 'spec/factories' if Dir.exist?('spec/factories')
      FactorySeeder.configuration.factory_paths << 'test/factories' if Dir.exist?('test/factories')

      # Enable verbose mode in development
      FactorySeeder.configuration.verbose = Rails.env.development? if Rails.respond_to?(:env)
    end

    def self.load_models
      return unless defined?(Rails) && Rails.respond_to?(:application) && Rails.application
      return if Rails.application.config.eager_load

      # Force eager loading when Rails hasn't done it (development/test with lazy loading)
      Rails.application.eager_load!
    end
  end
end
