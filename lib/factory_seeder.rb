# frozen_string_literal: true

require 'factory_bot'
require 'thor'
require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'faker'
require 'zeitwerk'

require_relative 'factory_seeder/version'

module FactorySeeder
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def loader
      Loader
    end

    def reload!
      Loader.reload!
      CustomSeedLoader.reload!
    end

    def scan_factories
      # Ensure Rails integration is properly set up
      FactorySeeder::RailsIntegration.setup
      FactorySeeder::RailsIntegration.load_models

      scanner = FactoryScanner.new
      scanner.scan
    end

    # Méthode simplifiée qui ne liste que les noms des factories
    def list_factory_names
      FactoryBot.factories.map(&:name).map(&:to_s)
    end

    def seeder
      @seeder ||= Seeder.new
    end

    def seed_manager
      @seed_manager ||= SeedManager.new
    end

    def generate
      yield(seeder) if block_given?
      seeder
    end

    def define_seed(name, builder_block = nil, &execution_block)
      seed_manager.define(name, builder_block, &execution_block)
    end

    def list_seeds
      # Keep backward compatibility with old seeder
      seeder.seeds
    end

    def list_custom_seeds
      seed_manager.list
    end

    def find_custom_seed(name)
      seed_manager.find(name)
    end

    def run_custom_seed(name, **kwargs)
      seed_manager.run(name, **kwargs)
    end

    def execution_logs
      Thread.current[:factory_seeder_execution_logs] ||= []
    end

    def clear_execution_logs!
      Thread.current[:factory_seeder_execution_logs] = []
    end

    def log(message, level: :info, **meta)
      entry = {
        message: message.to_s,
        level: level.to_sym,
        timestamp: Time.now,
        meta: meta
      }
      execution_logs << entry
      entry
    end

    %i[info success warning error].each do |level_name|
      define_method("log_#{level_name}") do |message, **meta|
        log(message, level: level_name, **meta)
      end
    end

    def normalized_logs(log_entries)
      Array(log_entries).map do |log_entry|
        timestamp = log_entry[:timestamp]
        formatted_timestamp =
          if timestamp.respond_to?(:iso8601)
            timestamp.iso8601
          else
            timestamp.to_s
          end

        {
          'message' => log_entry[:message].to_s,
          'level' => log_entry[:level].to_s,
          'timestamp' => formatted_timestamp,
          'meta' => log_entry[:meta] || {}
        }
      end
    end

    def run(*names)
      seeder.run(*names)
    end

    # Nouvelle méthode pour scanner les factories déjà chargées
    def scan_loaded_factories
      # Ensure Rails integration is properly set up
      FactorySeeder::RailsIntegration.setup
      FactorySeeder::RailsIntegration.load_models

      factories = {}

      FactoryBot.factories.each do |factory|
        factory_name = factory.name.to_s
        begin
          # Use a safer approach to get class name without building the class
          class_name = factory_name.classify

          # Try to get the actual class name if possible, but don't fail if it doesn't work
          begin
            class_name = factory.build_class.name if factory.respond_to?(:build_class) && factory.build_class
          rescue NameError, StandardError => e
            # If we can't get the actual class name, use the inferred one
            puts "⚠️  Using inferred class name for '#{factory_name}': #{e.message}" if configuration.verbose
          end

          factories[factory_name] = {
            name: factory_name,
            class_name: class_name,
            traits: extract_traits(factory),
            associations: extract_associations(factory),
            attributes: extract_attributes(factory)
          }
        rescue NameError => e
          puts "⚠️  Skipping factory '#{factory_name}': #{e.message}" if configuration.verbose
        rescue StandardError => e
          puts "⚠️  Error analyzing factory '#{factory_name}': #{e.message}" if configuration.verbose
        end
      end

      factories
    end

    private

    def extract_traits(factory)
      factory.definition.defined_traits.map(&:name).map(&:to_s)
    end

    def extract_associations(factory)
      associations = []

      factory.definition.declarations.each do |declaration|
        next unless declaration.is_a?(FactoryBot::Declaration::Association)

        factory_name = declaration.name.to_s
        associations << {
          name: factory_name,
          factory: factory_name.singularize,
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

require_relative 'factory_seeder/loader'
FactorySeeder::Loader.setup

require_relative 'factory_seeder/engine'
