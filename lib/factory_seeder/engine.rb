module FactorySeeder
  class Engine < ::Rails::Engine
    isolate_namespace FactorySeeder

    # Optionnel : configuration des générateurs
    config.generators do |g|
      g.test_framework :rspec
      g.template_engine :erb
    end
  end
end
