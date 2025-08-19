# frozen_string_literal: true

module FactorySeeder
  module RailsIntegration
    def self.setup
      return unless defined?(Rails)

      # Ensure models are loaded before scanning factories
      if Rails.respond_to?(:application) && Rails.application && Rails.application.config.eager_load
        Rails.application.eager_load!
      end

      # Add Rails-specific factory paths
      FactorySeeder.configuration.factory_paths << 'spec/factories' if Dir.exist?('spec/factories')
      FactorySeeder.configuration.factory_paths << 'test/factories' if Dir.exist?('test/factories')

      # Enable verbose mode in development
      FactorySeeder.configuration.verbose = Rails.env.development? if Rails.respond_to?(:env)
    end

    def self.load_models
      return unless defined?(Rails)

      # Load all models
      if Rails.respond_to?(:application) && Rails.application && Rails.application.config.eager_load
        Rails.application.eager_load!
      elsif Rails.respond_to?(:root)
        # Alternative: manually load models if eager_load is disabled
        Dir.glob(Rails.root.join('app/models/**/*.rb')).each do |file|
          require_dependency file
        end
      end
    end
  end
end
