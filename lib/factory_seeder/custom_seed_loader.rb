# frozen_string_literal: true

require 'pathname'

module FactorySeeder
  class CustomSeedLoader
    class << self
      # Only the seeds this loader registered are dropped: seeds declared
      # elsewhere -- an initializer, a console session -- must survive a reload.
      def reload!
        return unless seed_files.any?

        unload_previous!
        known = FactorySeeder.seed_manager.list_names

        seed_files.each do |file|
          load file
        rescue StandardError => e
          warn "⚠️  Could not load custom seed #{file}: #{e.message}"
        end

        @loaded_names = FactorySeeder.seed_manager.list_names - known
      end

      def unload_previous!
        Array(@loaded_names).each { |name| FactorySeeder.seed_manager.remove(name) }
        @loaded_names = []
      end

      def seed_files
        return [] unless seeds_directory

        Dir.glob(seeds_directory.join('**/*.rb'))
      end

      def seeds_directory
        base_path = if defined?(Rails) && Rails.respond_to?(:root)
                      Rails.root
                    else
                      Pathname.new(Dir.pwd)
                    end

        path = base_path.join('db', 'factory_seeds')
        return path if path.exist?

        nil
      end
    end
  end
end
