# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'
require 'stringio'

require 'factory_seeder'

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |file| require file }

RSpec.configure do |config|
  config.expect_with(:rspec) { |expectations| expectations.include_chain_clauses_in_custom_matcher_descriptions = true }
  config.mock_with(:rspec) { |mocks| mocks.verify_partial_doubles = true }
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.include TestModels::Helpers
  config.include CaptureOutput

  config.before do
    TestModels.reset!
    TestFactories.define!
    FactorySeeder.instance_variable_set(:@configuration, nil)
    FactorySeeder.instance_variable_set(:@seed_manager, nil)
    FactorySeeder.clear_execution_logs!
  end
end
