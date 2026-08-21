# frozen_string_literal: true

RSpec.describe FactorySeeder::SeedManager do
  subject(:manager) { described_class.new }

  def define_seed(name = :demo, builder = nil, &block)
    manager.define(name, builder, &block)
  end

  describe '#define and #find' do
    it 'registers a seed under its name' do
      seed = define_seed { :done }

      expect(manager.find(:demo)).to eq(seed)
      expect(manager).to be_exists(:demo)
    end

    it 'looks a seed up by string' do
      define_seed { :done }

      expect(manager.find('demo')).not_to be_nil
    end

    it 'rejects anything that is not a Seed' do
      expect { manager.register(:not_a_seed) }.to raise_error(ArgumentError, /must be a FactorySeeder::Seed/)
    end
  end

  describe '#run' do
    it 'raises when the seed is unknown' do
      expect { manager.run(:missing) }.to raise_error(ArgumentError, /not found/)
    end

    it 'returns the block result' do
      define_seed { :produced }

      expect(manager.run(:demo)).to include(success: true, seed_name: :demo, result: :produced)
    end

    it 'reports the records the seed created' do
      define_seed { FactoryBot.create(:fs_author) }

      result = manager.run(:demo)

      expect(result[:created_records].size).to eq(1)
      expect(result[:records_summary].first).to include('model' => 'TestModels::Author', 'count' => 1)
    end

    it 'describes what was created in its message' do
      define_seed { 2.times { FactoryBot.create(:fs_author) } }

      expect(manager.run(:demo)[:message]).to include('2 records created (TestModels::Author: 2)')
    end

    it 'reports a seed that creates nothing' do
      define_seed { :nothing }

      expect(manager.run(:demo)[:message]).to include('no record created')
    end

    it 'captures a failure without raising' do
      define_seed { raise 'kaboom' }

      result = manager.run(:demo)

      expect(result).to include(success: false, error: 'kaboom')
    end

    it 'keeps the records created before the failure' do
      define_seed do
        FactoryBot.create(:fs_author)
        raise 'kaboom'
      end

      result = manager.run(:demo)

      expect(result[:created_records].size).to eq(1)
      expect(result[:message]).to include('1 record created (TestModels::Author: 1) before failure')
    end

    it 'passes keyword arguments through' do
      define_seed(:demo, ->(builder) { builder.integer_param(:count, required: true) }) { |count:| count * 2 }

      expect(manager.run(:demo, count: 3)[:result]).to eq(6)
    end

    it 'fails when a required parameter is missing' do
      define_seed(:demo, ->(builder) { builder.integer_param(:count, required: true) }) { |count:| count }

      expect(manager.run(:demo)[:error]).to include('Missing required parameters: count')
    end

    it 'discards whatever was logged before the seed started' do
      define_seed { :ok }
      FactorySeeder.log_info('stray line from somewhere else')

      result = manager.run(:demo)

      expect(result[:logs].map { |log| log['message'] }).not_to include('stray line from somewhere else')
    end

    it 'returns the execution logs and clears them' do
      define_seed { FactoryBot.create(:fs_author) }

      result = manager.run(:demo)

      expect(result[:logs]).not_to be_empty
      expect(FactorySeeder.execution_logs).to be_empty
    end
  end

  describe '#validate_seed' do
    it 'is true for valid parameters' do
      define_seed(:demo, ->(builder) { builder.integer_param(:count, required: true, min: 1, max: 5) }) { :ok }

      expect(manager.validate_seed(:demo, count: 3)).to be(true)
    end

    it 'is false for invalid parameters' do
      define_seed(:demo, ->(builder) { builder.integer_param(:count, required: true, min: 1, max: 5) }) { :ok }

      expect(manager.validate_seed(:demo, count: 50)).to be(false)
    end
  end

  describe '#search' do
    it 'matches on name, description and parameter names' do
      define_seed(:users, ->(builder) { builder.description('Creates people').string_param(:country) }) { :ok }

      expect(manager.search('user').map(&:name)).to eq([:users])
      expect(manager.search('people').map(&:name)).to eq([:users])
      expect(manager.search('country').map(&:name)).to eq([:users])
      expect(manager.search('nothing')).to be_empty
    end
  end

  describe '#clear, #count and #empty?' do
    it 'tracks the registry size' do
      expect(manager).to be_empty

      define_seed { :ok }
      expect(manager.count).to eq(1)

      manager.clear
      expect(manager).to be_empty
    end
  end

  describe 'the removed run-all API' do
    it 'no longer exposes run_all' do
      expect(manager).not_to respond_to(:run_all)
    end
  end
end
