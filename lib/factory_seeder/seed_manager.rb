# frozen_string_literal: true

module FactorySeeder
  class SeedManager
    attr_reader :seeds

    def initialize
      @seeds = {}
    end

    def register(seed)
      raise ArgumentError, 'Seed must be a FactorySeeder::Seed instance' unless seed.is_a?(Seed)

      @seeds[seed.name] = seed
    end

    def define(name, builder_block = nil, &execution_block)
      builder = SeedBuilder.new(name)
      builder_block&.call(builder)
      seed = builder.build(&execution_block)
      register(seed)
      seed
    end

    def remove(name)
      @seeds.delete(name.to_sym)
    end

    def find(name)
      @seeds[name.to_sym]
    end

    def exists?(name)
      @seeds.key?(name.to_sym)
    end

    def list
      @seeds.values
    end

    def list_names
      @seeds.keys
    end

    def run(name, **kwargs)
      seed = find(name)
      raise ArgumentError, "Seed '#{name}' not found" unless seed

      FactorySeeder.clear_execution_logs!
      FactorySeeder.log_info("Running custom seed '#{name}'", kwargs: kwargs)

      created_records = []

      begin
        result = RecordTracker.capture(created_records) { seed.call(**kwargs) }
        RecordTracker.log_summary(created_records)
        FactorySeeder.log_success("Seed '#{name}' completed", result: result)
        logs = FactorySeeder.normalized_logs(FactorySeeder.execution_logs)
        FactorySeeder.clear_execution_logs!
        {
          success: true,
          seed_name: name,
          result: result,
          created_records: created_records,
          records_summary: RecordTracker.summarize(created_records),
          message: "Seed '#{name}' executed successfully — #{RecordTracker.describe(created_records)}",
          logs: logs
        }
      rescue StandardError => e
        RecordTracker.log_summary(created_records)
        FactorySeeder.log("Seed '#{name}' failed: #{e.message}", level: :error)
        logs = FactorySeeder.normalized_logs(FactorySeeder.execution_logs)
        FactorySeeder.clear_execution_logs!
        {
          success: false,
          seed_name: name,
          error: e.message,
          created_records: created_records,
          records_summary: RecordTracker.summarize(created_records),
          message: "Seed '#{name}' failed: #{e.message} (#{RecordTracker.describe(created_records)} before failure)",
          logs: logs
        }
      end
    end

    def validate_seed(name, **kwargs)
      seed = find(name)
      raise ArgumentError, "Seed '#{name}' not found" unless seed

      seed.validate_parameters!(kwargs)
      true
    rescue StandardError
      false
    end

    def get_seed_info(name)
      seed = find(name)
      return nil unless seed

      seed.to_h
    end

    def search(query)
      query = query.to_s.downcase
      @seeds.values.select do |seed|
        seed.name.to_s.downcase.include?(query) ||
          seed.description.downcase.include?(query) ||
          seed.parameter_names.any? { |param| param.to_s.downcase.include?(query) }
      end
    end

    def clear
      @seeds.clear
    end

    def count
      @seeds.count
    end

    def empty?
      @seeds.empty?
    end
  end
end
