# frozen_string_literal: true

module FactorySeeder
  class Seeder
    attr_reader :seeds

    def initialize
      @seeds = {}
    end

    def seed(name, &block)
      @seeds[name.to_sym] = block
    end

    def run(name, **kwargs)
      name = to_sym(name)
      seed = @seeds[name]

      raise ArgumentError, "Seed #{name} not defined" unless seed

      result = @seeds[name].call(**kwargs)
      if result
        puts "🌱 Seed #{name} generated successfully"
        true
      else
        puts "⚠️  Seed #{name} failed"
        false
      end
    end

    private

    def to_sym(name)
      if name.is_a?(Symbol)
        name
      else
        name.to_sym
      end
    end
  end
end
