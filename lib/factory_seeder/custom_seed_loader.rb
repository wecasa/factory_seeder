# frozen_string_literal: true

require 'pathname'

module FactorySeeder
  class CustomSeedLoader
    class << self
      def reload!
        return unless seed_files.any?

        FactorySeeder.seed_manager.clear
        seed_files.each do |file|
          load file
        rescue StandardError => e
          warn "⚠️  Could not load custom seed #{file}: #{e.message}"
        end
      end

      def seed_files
        return [] unless seeds_directory

        Dir.glob(seeds_directory.join('*.rb'))
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
