# frozen_string_literal: true

module FactorySeeder
  class SeedManager
    attr_reader :seeds

    def initialize
      @seeds = {}
    end

    def register(seed)
      raise ArgumentError, "Seed must be a FactorySeeder::Seed instance" unless seed.is_a?(Seed)
      @seeds[seed.name] = seed
    end

    def define(name, builder_block = nil, &execution_block)
      builder = SeedBuilder.new(name)
      builder_block&.call(builder)
      seed = builder.build(&execution_block)
      register(seed)
      seed
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

      begin
        result = seed.call(**kwargs)
        {
          success: true,
          seed_name: name,
          result: result,
          message: "Seed '#{name}' executed successfully"
        }
      rescue StandardError => e
        {
          success: false,
          seed_name: name,
          error: e.message,
          message: "Seed '#{name}' failed: #{e.message}"
        }
      end
    end

    def run_all(**global_kwargs)
      results = []
      
      @seeds.each do |name, seed|
        result = run(name, **global_kwargs)
        results << result
      end

      {
        total_seeds: @seeds.count,
        successful: results.count { |r| r[:success] },
        failed: results.count { |r| !r[:success] },
        results: results
      }
    end

    def validate_seed(name, **kwargs)
      seed = find(name)
      raise ArgumentError, "Seed '#{name}' not found" unless seed

      seed.validate_parameters!(kwargs)
      true
    rescue StandardError => e
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
