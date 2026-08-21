# frozen_string_literal: true

RSpec.describe FactorySeeder::SeedGenerator do
  subject(:generator) { described_class.new }

  describe '#generate' do
    it 'creates the requested number of records' do
      result = generator.generate(:fs_author, 3)

      expect(result).to include(factory: :fs_author, count: 3, requested_count: 3, errors: [])
    end

    it 'reports the created records, associations included' do
      result = generator.generate(:fs_article, 2)

      expect(result[:created_records].map { |entry| entry['model'] })
        .to contain_exactly('TestModels::Author', 'TestModels::Article',
                            'TestModels::Author', 'TestModels::Article')
    end

    it 'summarises the created records' do
      result = generator.generate(:fs_author, 2)

      expect(result[:records_summary])
        .to eq([{ 'model' => 'TestModels::Author', 'count' => 2, 'ids' => [1, 2] }])
    end

    it 'returns the execution logs' do
      result = generator.generate(:fs_author, 1)

      expect(result[:logs].map { |log| log['message'] })
        .to include(a_string_including('Created TestModels::Author'), a_string_including('1 record created'))
    end

    it 'leaves no execution log behind' do
      generator.generate(:fs_author, 1)

      expect(FactorySeeder.execution_logs).to be_empty
    end

    it 'records nothing when the factory is unknown' do
      result = generator.generate(:does_not_exist, 1)

      expect(result[:count]).to eq(0)
      expect(result[:errors].first).to include('does_not_exist')
      expect(result[:created_records]).to be_empty
    end

    it 'keeps the records created before a failure' do
      allow(FactoryBot).to receive(:create).and_call_original
      allow(FactoryBot).to receive(:create).with(:fs_article, {}).and_wrap_original do |original, *args|
        FactoryBot.create(:fs_author)
        original.call(*args)
        raise 'boom'
      end

      result = generator.generate(:fs_article, 1)

      expect(result[:errors].size).to eq(1)
      expect(result[:created_records].size).to eq(3)
    end

    context 'with the build strategy' do
      it 'saves and reports the built records' do
        result = generator.generate(:fs_author, 2, [], {}, 'build')

        expect(result[:count]).to eq(2)
        expect(result[:created_records].size).to eq(2)
      end

      it 'does not report records that were never persisted' do
        result = generator.generate(:fs_ghost, 2, [], {}, 'build')

        expect(result[:created_records]).to be_empty
      end

      it 'still counts records the model cannot persist' do
        result = generator.generate(:fs_value, 3, [], {}, 'build')

        expect(result).to include(count: 3, errors: [])
        expect(result[:created_records]).to be_empty
        expect(generator.summary).to include('fs_value: 3 records')
      end
    end
  end

  describe '#preview' do
    it 'builds without persisting' do
      result = generator.preview(:fs_author, 2)

      expect(result[:count]).to eq(2)
      expect(TestModels::Author.sequence).to eq(0)
    end

    it 'returns the built attributes rather than an error stub' do
      entry = generator.preview(:fs_author, 1)[:preview].first

      expect(entry).not_to have_key(:error)
      expect(entry[:attributes]).to include('name' => 'Ada')
    end

    it 'reports the associations of the built record' do
      entry = generator.preview(:fs_article, 1)[:preview].first

      expect(entry).not_to have_key(:error)
      expect(entry[:associations]).to have_key(:author)
    end

    it 'applies the attributes it is given' do
      entry = generator.preview(:fs_author, 1, [], { name: 'Grace' })[:preview].first

      expect(entry[:attributes]).to include('name' => 'Grace')
    end
  end

  describe 'attribute filtering' do
    it 'applies a plain attribute' do
      result = generator.generate(:fs_author, 1, [], { name: 'Grace' })

      expect(result[:count]).to eq(1)
      expect(result[:created_records].first['label']).to eq('Grace')
    end

    it 'drops an attribute that names a has_many association' do
      result = generator.generate(:fs_blog, 1, [], { title: 'Kept', articles: %i[nope] })

      expect(result[:errors]).to be_empty
      expect(result[:count]).to eq(1)
    end

    it 'applies a trait alongside attributes' do
      result = generator.generate(:fs_traited, 1, [:famous], {})

      expect(result[:errors]).to be_empty
      expect(result[:created_records].map { |entry| entry['label'] }).to include('Grace')
    end
  end

  describe 'log isolation between runs' do
    it 'discards whatever was logged before the run started' do
      FactorySeeder.log_info('stray line from somewhere else')

      result = generator.generate(:fs_author, 1)

      expect(result[:logs].map { |log| log['message'] }).not_to include('stray line from somewhere else')
    end

    it 'does not carry one run logs into the next' do
      first = generator.generate(:fs_author, 2)
      second = described_class.new.generate(:fs_blog, 1)

      expect(first[:logs].map { |log| log['message'] }).to include(a_string_including('Starting fs_author'))
      expect(second[:logs].map { |log| log['message'] }).not_to include(a_string_including('fs_author'))
    end

    it 'summarises only the records of the run it belongs to' do
      generator.generate(:fs_author, 2)
      second = described_class.new.generate(:fs_blog, 1)

      summary = second[:logs].filter_map { |log| log['meta'][:models] }.last

      expect(summary).to eq('TestModels::Blog' => 1)
    end
  end

  describe '#summary' do
    it 'reports when nothing was generated' do
      expect(generator.summary).to eq('No records generated')
    end

    it 'groups the generated records by factory' do
      generator.generate(:fs_author, 2)

      expect(generator.summary).to include('fs_author: 2 records')
    end
  end

  describe 'the removed run-all API' do
    it 'no longer exposes run_all_seeds' do
      expect(generator).not_to respond_to(:run_all_seeds)
    end
  end
end
