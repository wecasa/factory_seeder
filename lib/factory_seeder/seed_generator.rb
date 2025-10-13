# frozen_string_literal: true

module FactorySeeder
  class SeedGenerator
    def initialize
      @generated_records = []
      @defined_seeds = {}
    end

    def preview(factory_name, count = 1, traits = [], attributes = {})
      traits = traits.map(&:to_sym)

      preview_data = []
      count.times do |i|
        # Build without saving
        record = FactoryBot.build(factory_name, *traits, attributes)

        preview_data << {
          index: i + 1,
          attributes: record.attributes,
          associations: extract_associations(record)
        }
      rescue StandardError => e
        preview_data << {
          index: i + 1,
          error: e.message
        }
      end

      {
        factory: factory_name,
        count: count,
        traits: traits,
        attributes: attributes,
        preview: preview_data
      }
    end

    def generate(factory_name, count = 1, traits = [], attributes = {}, strategy = 'create')
      traits = traits.map(&:to_sym)

      generated_count = 0
      errors = []

      count.times do |i|
        if strategy == 'create'
          record = FactoryBot.create(factory_name, *traits, attributes)
        else
          record = FactoryBot.build(factory_name, *traits, attributes)
          record.save! if record.respond_to?(:save!)
        end

        @generated_records << {
          factory: factory_name,
          record: record,
          traits: traits,
          attributes: attributes,
          strategy: strategy
        }

        generated_count += 1

        puts "✅ Generated #{factory_name} ##{i + 1}" if FactorySeeder.configuration.verbose
      rescue StandardError => e
        error_msg = "Failed to generate #{factory_name} ##{i + 1}: #{e.message}"
        errors << error_msg
        puts "❌ #{error_msg}" if FactorySeeder.configuration.verbose
      end

      {
        factory: factory_name,
        generated_records: @generated_records,
        count: generated_count,
        requested_count: count,
        traits: traits,
        attributes: attributes,
        strategy: strategy,
        errors: errors
      }
    end

    def summary
      return 'No records generated' if @generated_records.empty?

      summary = "📊 Generation Summary:\n"
      summary += "#{'=' * 50}\n"

      by_factory = @generated_records.group_by { |r| r[:factory] }

      by_factory.each do |factory_name, records|
        summary += "\n🏭 #{factory_name}: #{records.count} records\n"
        records.each_with_index do |record, index|
          summary += "   #{index + 1}. Strategy: #{record[:strategy]}"
          summary += ", Traits: #{record[:traits].join(', ')}" if record[:traits].any?
          summary += ", Attributes: #{record[:attributes]}" if record[:attributes].any?
          summary += "\n"
        end
      end

      summary
    end

    def define_seed(name, &block)
      @defined_seeds[name.to_sym] = block
    end

    def run_seed(name)
      seed_name = name.to_sym
      unless @defined_seeds.key?(seed_name)
        raise "Seed '#{name}' not found. Available seeds: #{@defined_seeds.keys.join(', ')}"
      end

      @defined_seeds[seed_name].call(self)
    end

    def list_seeds
      @defined_seeds.keys
    end

    def has_seed?(name)
      @defined_seeds.key?(name.to_sym)
    end

    def run_all_seeds
      puts '🌱 Running all defined seeds...'
      @defined_seeds.each do |name, block|
        puts "\n--- Running seed: #{name} ---"
        block.call(self)
      end
      puts "\n✅ All seeds completed successfully"
    end

    private

    def extract_associations(record)
      associations = {}

      record.class.reflect_on_all_associations.each do |association|
        if association.macro == :belongs_to
          associated_record = record.send(association.name)
          associations[association.name] = associated_record&.id if associated_record
        elsif association.macro == :has_many
          associated_records = record.send(association.name)
          associations[association.name] = associated_records.map(&:id) if associated_records.any?
        end
      rescue StandardError => e
        associations[association.name] = "Error: #{e.message}"
      end

      associations
    end
  end
end
