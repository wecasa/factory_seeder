# frozen_string_literal: true

module FactorySeeder
  class Configuration
    attr_accessor :factory_paths, :default_count, :default_strategy, :environments, :verbose

    def initialize
      @factory_paths = []
      @default_count = 1
      @default_strategy = :create
      @verbose = false
      @environments = {
        development: { default_count: 10 },
        test: { default_count: 5 },
        production: { default_count: 1 }
      }
    end

    def environment_settings
      current_env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      @environments[current_env.to_sym] || @environments[:development]
    end

    def default_count_for_environment
      environment_settings[:default_count] || @default_count
    end

    def default_strategy_for_environment
      environment_settings[:default_strategy] || @default_strategy
    end
  end
end
