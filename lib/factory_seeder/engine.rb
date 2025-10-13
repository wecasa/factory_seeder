# frozen_string_literal: true

module FactorySeeder
  class Engine < ::Rails::Engine
    isolate_namespace FactorySeeder

    config.generators do |g|
      g.test_framework :rspec
      g.template_engine :erb
    end

    config.after_initialize do
      custom_seeds_path = Rails.root.join('db', 'seeds_factory_seeder.rb')
      load custom_seeds_path if File.exist?(custom_seeds_path)
    end
  end
end
