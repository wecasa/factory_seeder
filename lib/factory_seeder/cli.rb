# frozen_string_literal: true

require 'thor'

module FactorySeeder
  class CLI < Thor
    class_option :verbose, type: :boolean, aliases: '-v', desc: 'Enable verbose output'

    desc 'generate [FACTORY]', 'Generate seeds for a specific factory'
    option :count, type: :numeric, default: 1, desc: 'Number of records to create'
    option :traits, type: :array, desc: 'Traits to apply'
    option :strategy, type: :string, default: 'create', desc: 'Factory strategy (create, build, etc.)'
    option :attributes, type: :hash, desc: 'Additional attributes'
    def generate(factory_name = nil)
      if factory_name
        generate_single_factory(factory_name)
      else
        interactive_generate
      end
    end

    desc 'list', 'List all available factories'
    option :verbose, type: :boolean, aliases: '-v'
    def list
      FactorySeeder.configuration.verbose = options[:verbose] if options[:verbose]

      # Utiliser list_factory_names pour éviter les problèmes de chargement
      factory_names = FactorySeeder.list_factory_names

      if factory_names.empty?
        puts '❌ No factories found. Make sure you have FactoryBot factories in spec/factories/ or test/factories/'
        return
      end

      puts "📋 Found #{factory_names.count} factories:\n\n"

      factory_names.each do |name|
        puts "🏭 #{name}"
      end
    end

    desc 'preview FACTORY_NAME', 'Preview factory data without creating records'
    option :count, type: :numeric, default: 1, aliases: '-c'
    option :traits, type: :string, aliases: '-t'
    option :attributes, type: :string, aliases: '-a'
    def preview(factory_name)
      FactorySeeder.configuration.verbose = true

      # Vérifier si la factory existe
      factory_names = FactorySeeder.list_factory_names
      unless factory_names.include?(factory_name)
        puts "❌ Factory '#{factory_name}' not found"
        puts "Available factories: #{factory_names.first(10).join(', ')}"
        return
      end

      traits = options[:traits]&.split(',')&.map(&:strip) || []
      attributes = parse_attributes(options[:attributes])

      generator = SeedGenerator.new
      preview_data = generator.preview(factory_name, options[:count], traits, attributes)

      puts "🔍 Preview for #{factory_name}:"
      puts JSON.pretty_generate(preview_data)
    end

    desc 'web', 'Start web interface'
    option :port, type: :numeric, default: 4567, aliases: '-p'
    option :host, type: :string, default: 'localhost', aliases: '-h'
    def web
      puts "🌐 Starting FactorySeeder web interface on http://#{options[:host]}:#{options[:port]}"
      puts 'Press Ctrl+C to stop'

      WebInterface.set :port, options[:port]
      WebInterface.set :bind, options[:host]
      WebInterface.run!
    end

    desc 'init', 'Initialize FactorySeeder configuration'
    def init
      puts '🚀 Initializing FactorySeeder...'

      FactorySeeder.configure do |config|
        config.factory_paths << 'spec/factories' if Dir.exist?('spec/factories')
        config.factory_paths << 'test/factories' if Dir.exist?('test/factories')
        config.verbose = true
      end

      puts '✅ FactorySeeder initialized!'
      puts 'Configuration:'
      puts "  Factory paths: #{FactorySeeder.configuration.factory_paths.join(', ')}"
      puts "  Verbose mode: #{FactorySeeder.configuration.verbose}"
    end

    private

    def interactive_generate
      factory_names = FactorySeeder.list_factory_names

      if factory_names.empty?
        puts '❌ No factories found'
        return
      end

      puts '🏭 Available factories:'
      factory_names.each_with_index do |name, index|
        puts "  #{index + 1}. #{name}"
      end

      print "\nSelect factory (number or name): "
      selection = STDIN.gets.chomp

      factory_name = if selection.match?(/^\d+$/)
                       index = selection.to_i - 1
                       factory_names[index]
                     else
                       selection
                     end

      unless factory_name && factory_names.include?(factory_name)
        puts '❌ Invalid selection'
        return
      end

      generate_single_factory(factory_name)
    end

    def generate_single_factory(factory_name)
      # Vérifier si la factory existe
      factory_names = FactorySeeder.list_factory_names
      unless factory_names.include?(factory_name)
        puts "❌ Factory '#{factory_name}' not found"
        return
      end

      traits = options[:traits] || []
      attributes = options[:attributes] || {}

      generator = SeedGenerator.new
      result = generator.generate(factory_name, options[:count], traits, attributes, options[:strategy])

      puts "✅ Generated #{result[:count]} #{factory_name} records"
      puts "Strategy: #{result[:strategy]}"
      puts "Traits: #{traits.join(', ')}" if traits.any?
      puts "Attributes: #{attributes}" if attributes.any?
    end

    def parse_attributes(attributes_string)
      return {} unless attributes_string

      attributes = {}
      attributes_string.split(',').each do |pair|
        key, value = pair.split('=').map(&:strip)
        attributes[key] = value if key && value
      end
      attributes
    end
  end
end
