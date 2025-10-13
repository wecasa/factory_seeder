# frozen_string_literal: true

# FactorySeeder Configuration
FactorySeeder.configure do |config|
  # Add custom factory paths if needed
  # config.factory_paths << "custom/factories"

  # Default options for seeding
  config.default_count = 1
  config.default_strategy = :create

  # Environment-specific settings
  config.environments = {
    development: {
      default_count: 10
    },
    test: {
      default_count: 5
    },
    production: {
      default_count: 1
    }
  }
end
