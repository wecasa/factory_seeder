# frozen_string_literal: true

module FactorySeeder
  class Engine < ::Rails::Engine
    isolate_namespace FactorySeeder

    config.generators do |g|
      g.test_framework :rspec
      g.template_engine :erb
    end

    config.to_prepare do
      FactorySeeder::CustomSeedLoader.reload!
    end
  end
end
