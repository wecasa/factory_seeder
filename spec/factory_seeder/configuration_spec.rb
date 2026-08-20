# frozen_string_literal: true

RSpec.describe FactorySeeder::Configuration do
  subject(:configuration) { described_class.new }

  it 'starts with the documented defaults' do
    expect(configuration).to have_attributes(
      factory_paths: [],
      default_count: 1,
      default_strategy: :create,
      verbose: false,
      log_records_limit: 50
    )
  end

  describe 'environment settings' do
    around do |example|
      original = ENV.fetch('RAILS_ENV', nil)
      example.run
      ENV['RAILS_ENV'] = original
    end

    it 'reads the count for the current environment' do
      ENV['RAILS_ENV'] = 'test'

      expect(configuration.default_count_for_environment).to eq(5)
    end

    it 'falls back to development for an unknown environment' do
      ENV['RAILS_ENV'] = 'staging'

      expect(configuration.default_count_for_environment).to eq(10)
    end

    it 'falls back to the global strategy when the environment has none' do
      ENV['RAILS_ENV'] = 'test'

      expect(configuration.default_strategy_for_environment).to eq(:create)
    end
  end

  describe 'FactorySeeder.configure' do
    it 'yields the configuration' do
      FactorySeeder.configure { |config| config.log_records_limit = 7 }

      expect(FactorySeeder.configuration.log_records_limit).to eq(7)
    end
  end
end
