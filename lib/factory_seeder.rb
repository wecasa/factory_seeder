# frozen_string_literal: true

require 'factory_bot'
require 'thor'
require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'faker'

require_relative 'factory_seeder/version'
require_relative 'factory_seeder/configuration'
require_relative 'factory_seeder/factory_scanner'
require_relative 'factory_seeder/seed_generator'
require_relative 'factory_seeder/cli'
require_relative 'factory_seeder/web_interface'
require_relative 'factory_seeder/rails_integration'

module FactorySeeder
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def scan_factories
      scanner = FactoryScanner.new
      scanner.scan
    end

    # Méthode simplifiée qui ne liste que les noms des factories
    def list_factory_names
      FactoryBot.factories.map(&:name).map(&:to_s)
    end

    # Nouvelle méthode pour scanner les factories déjà chargées
    def scan_loaded_factories
      factories = {}

      FactoryBot.factories.each do |factory|
        factory_name = factory.name.to_s
        begin
          # Éviter de charger le modèle en utilisant factory.klass ou factory.build_class
          # Utiliser factory.name pour déduire le nom de la classe
          class_name = factory_name.classify

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
