# frozen_string_literal: true

module FactorySeeder
  class FactoryScanner
    def initialize
      @factories = {}
      @factory_paths = find_factory_paths
    end

    def scan
      # Setup Rails integration if available
      FactorySeeder::RailsIntegration.setup
      FactorySeeder::RailsIntegration.load_models

      load_factories
      analyze_factories
      @factories
    end

    private

    def find_factory_paths
      paths = []

      # Rails convention
      paths << 'spec/factories' if Dir.exist?('spec/factories')
      paths << 'test/factories' if Dir.exist?('test/factories')
      paths << 'factories' if Dir.exist?('factories')

      # Custom paths from configuration
      paths.concat(FactorySeeder.configuration.factory_paths)

      paths.uniq
    end

    def load_factories
      @factory_paths.each do |path|
        Dir.glob("#{path}/**/*.rb").each do |file|
          load file
        rescue FactoryBot::DuplicateDefinitionError => e
          # Skip if factory is already registered
          puts "⚠️  Factory already registered: #{e.message}" if FactorySeeder.configuration.verbose
        rescue NameError => e
          # Handle uninitialized constant errors
          puts "⚠️  Model not loaded yet: #{e.message}" if FactorySeeder.configuration.verbose
          # Store the file to retry later
          @retry_files ||= []
          @retry_files << file
        end
      end

      # Retry loading files that failed due to missing models
      retry_loading_factories if @retry_files&.any?
    end

    def retry_loading_factories
      return unless @retry_files&.any?

      puts '🔄 Retrying to load factories that failed...' if FactorySeeder.configuration.verbose

      @retry_files.each do |file|
        load file
        puts "✅ Successfully loaded: #{file}" if FactorySeeder.configuration.verbose
      rescue StandardError => e
        puts "❌ Still failed to load #{file}: #{e.message}" if FactorySeeder.configuration.verbose
      end

      @retry_files = []
    end

    def analyze_factories
      FactoryBot.factories.each do |factory|
        factory_name = factory.name.to_s
        begin
          class_name = factory.build_class.name
          @factories[factory_name] = {
            name: factory_name,
            class_name: class_name,
            traits: extract_traits(factory),
            associations: extract_associations(factory),
            attributes: extract_attributes(factory)
          }
        rescue NameError => e
          # Skip factories with missing model classes
          puts "⚠️  Skipping factory '#{factory_name}': #{e.message}" if FactorySeeder.configuration.verbose
        rescue StandardError => e
          # Skip factories with other errors
          puts "⚠️  Error analyzing factory '#{factory_name}': #{e.message}" if FactorySeeder.configuration.verbose
        end
      end
    end

    def extract_traits(factory)
      factory.definition.defined_traits.map(&:name).map(&:to_s)
    end

    def extract_associations(factory)
      associations = []

      factory.definition.declarations.each do |declaration|
        next unless declaration.is_a?(FactoryBot::Declaration::Association)

        # Try to get factory name from the association name
        factory_name = declaration.name.to_s

        associations << {
          name: factory_name,
          factory: factory_name.singularize, # Assume factory name matches association
          strategy: 'create'
        }
      end

      associations
    end

    def extract_attributes(factory)
      attributes = []

      factory.definition.declarations.each do |declaration|
        next if declaration.is_a?(FactoryBot::Declaration::Association)

        attributes << {
          name: declaration.name.to_s,
          type: declaration.class.name.demodulize.downcase
        }
      end

      attributes
    end
  end
end
