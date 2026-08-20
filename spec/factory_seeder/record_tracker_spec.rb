# frozen_string_literal: true

RSpec.describe FactorySeeder::RecordTracker do
  describe '.capture' do
    it 'collects the records FactoryBot persists' do
      collected = []

      described_class.capture(collected) { FactoryBot.create(:fs_author) }

      expect(collected).to contain_exactly('model' => 'TestModels::Author', 'id' => 1, 'label' => 'Ada')
    end

    it 'collects records created through associations' do
      collected = []

      described_class.capture(collected) { FactoryBot.create(:fs_article) }

      expect(collected.map { |entry| entry['model'] })
        .to contain_exactly('TestModels::Author', 'TestModels::Article')
    end

    it 'returns the block value' do
      expect(described_class.capture([]) { :done }).to eq(:done)
    end

    it 'keeps the records created before the block raises' do
      collected = []

      expect do
        described_class.capture(collected) do
          FactoryBot.create(:fs_author)
          raise 'boom'
        end
      end.to raise_error('boom')

      expect(collected.size).to eq(1)
    end

    it 'tracks nothing outside of a capture' do
      collected = []
      described_class.capture(collected) { nil }

      FactoryBot.create(:fs_author)

      expect(collected).to be_empty
    end

    it 'reports inner records to the enclosing capture' do
      outer = []
      inner = []

      described_class.capture(outer) do
        FactoryBot.create(:fs_author)
        described_class.capture(inner) { FactoryBot.create(:fs_author) }
      end

      expect([outer.size, inner.size]).to eq([2, 1])
    end

    it 'does not duplicate entries when nesting reuses the same array' do
      collected = []

      described_class.capture(collected) do
        FactoryBot.create(:fs_author)
        described_class.capture(collected) { FactoryBot.create(:fs_author) }
      end

      expect(collected.size).to eq(2)
    end

    it 'collects records created inside a fiber' do
      collected = []

      described_class.capture(collected) do
        Enumerator.new { |yielder| yielder << FactoryBot.create(:fs_author) }.next
      end

      expect(collected.size).to eq(1)
    end
  end

  describe 'callback registration' do
    it 'survives FactoryBot.reload, which discards global callbacks' do
      described_class.install!
      FactoryBot.reload
      TestFactories.define!

      collected = []
      described_class.capture(collected) { FactoryBot.create(:fs_author) }

      expect(collected.size).to eq(1)
    end

    it 'reports the callback as gone once FactoryBot drops it' do
      described_class.install!
      expect(described_class).to be_installed

      FactoryBot.reload

      expect(described_class).not_to be_installed
    end

    it 'does not register a second callback while introspection is unavailable' do
      described_class.install!
      allow(described_class).to receive(:registered_callbacks).and_return(nil)
      described_class.install!
      allow(described_class).to receive(:registered_callbacks).and_call_original

      collected = []
      described_class.capture(collected) { FactoryBot.create(:fs_author) }

      expect(collected.size).to eq(1)
    end

    it 'never registers the callback twice' do
      5.times { described_class.install! }

      collected = []
      described_class.capture(collected) { FactoryBot.create(:fs_author) }

      expect(collected.size).to eq(1)
    end
  end

  describe '.track' do
    it 'does not let a raising label escape the after(:create) callback' do
      collected = []

      expect { described_class.capture(collected) { FactoryBot.create(:fs_hostile) } }.not_to raise_error
      expect(collected.first).to include('model' => 'TestModels::Hostile', 'label' => nil)
    end

    it 'ignores records that were never persisted' do
      collected = []

      described_class.capture(collected) { FactoryBot.create(:fs_ghost) }

      expect(collected).to be_empty
    end

    it 'skips an association when building a label, without reading it' do
      collected = []

      described_class.capture(collected) { FactoryBot.create(:fs_associated) }

      expect(collected.first['label']).to eq('safe-title')
      expect(TestModels::WithAssociation.association_reads).to eq(0)
    end

    it 'skips labels that are blank or not scalars' do
      collected = []

      described_class.capture(collected) { FactoryBot.create(:fs_odd_labels) }

      expect(collected.first['label']).to eq('usable-label')
    end

    it 'names an anonymous class rather than reporting no model' do
      anonymous = Class.new(TestModels::Author)
      FactoryBot.define { factory(:fs_anonymous, class: anonymous) }
      collected = []

      described_class.capture(collected) { FactoryBot.create(:fs_anonymous) }

      expect(collected.first['model']).to match(/\A#<Class:0x/)
    end

    it 'keeps FactoryBot.create working when the tracker itself breaks' do
      allow(described_class).to receive(:entry_for).and_raise('tracker exploded')
      collected = []

      expect { described_class.capture(collected) { FactoryBot.create(:fs_author) } }.not_to raise_error
      expect(collected).to be_empty
    end
  end

  describe '.summarize' do
    it 'groups entries by model, most numerous first' do
      entries = [
        create_entry(model: 'Article', id: 1),
        create_entry(model: 'Author', id: 2),
        create_entry(model: 'Author', id: 3)
      ]

      expect(described_class.summarize(entries)).to eq(
        [
          { 'model' => 'Author', 'count' => 2, 'ids' => [2, 3] },
          { 'model' => 'Article', 'count' => 1, 'ids' => [1] }
        ]
      )
    end

    it 'drops missing ids from the id list' do
      entries = [create_entry(model: 'Author', id: nil), create_entry(model: 'Author', id: 4)]

      expect(described_class.summarize(entries).first).to include('count' => 2, 'ids' => [4])
    end

    it 'accepts nil and a bare entry' do
      expect(described_class.summarize(nil)).to eq([])
      expect(described_class.summarize(create_entry(model: 'Author', id: 1)).first).to include('count' => 1)
    end
  end

  describe '.describe' do
    it 'reports when nothing was created' do
      expect(described_class.describe([])).to eq('no record created')
    end

    it 'uses the singular for a single record' do
      expect(described_class.describe([create_entry(model: 'Author', id: 1)]))
        .to eq('1 record created (Author: 1)')
    end

    it 'lists every model with its count, alphabetically on equal counts' do
      entries = [create_entry(model: 'Author', id: 1), create_entry(model: 'Article', id: 2)]

      expect(described_class.describe(entries)).to eq('2 records created (Article: 1, Author: 1)')
    end
  end

  describe '.format_entry' do
    it 'renders the model, id and label' do
      expect(described_class.format_entry(create_entry(model: 'Author', id: 7, label: 'Ada')))
        .to eq('Author #7 (Ada)')
    end

    it 'omits the parts it does not have' do
      expect(described_class.format_entry(create_entry(model: 'Author'))).to eq('Author')
    end
  end

  describe 'log output' do
    def logged_messages
      FactorySeeder.execution_logs.map { |entry| entry[:message] }
    end

    it 'logs one line per created record' do
      described_class.capture([]) { FactoryBot.create(:fs_author) }

      expect(logged_messages).to include(a_string_including('Created TestModels::Author #1 (Ada)'))
    end

    it 'stops logging individual records past the configured limit' do
      FactorySeeder.configuration.log_records_limit = 2

      described_class.capture([]) { 4.times { FactoryBot.create(:fs_author) } }

      expect(logged_messages.grep(/Created TestModels::Author/).size).to eq(2)
      expect(logged_messages).to include(a_string_including('2 records logged individually'))
    end

    it 'still collects the records it stops logging' do
      FactorySeeder.configuration.log_records_limit = 1
      collected = []

      described_class.capture(collected) { 3.times { FactoryBot.create(:fs_author) } }

      expect(collected.size).to eq(3)
    end

    it 'logs every record when the limit is nil' do
      FactorySeeder.configuration.log_records_limit = nil

      described_class.capture([]) { 3.times { FactoryBot.create(:fs_author) } }

      expect(logged_messages.grep(/Created TestModels::Author/).size).to eq(3)
    end

    it 'logs no individual record when the limit is zero' do
      FactorySeeder.configuration.log_records_limit = 0

      described_class.capture([]) { FactoryBot.create(:fs_author) }

      expect(logged_messages).to be_empty
    end

    it 'restarts the limit on each top-level capture' do
      FactorySeeder.configuration.log_records_limit = 1

      2.times { described_class.capture([]) { FactoryBot.create(:fs_author) } }

      expect(logged_messages.grep(/Created TestModels::Author/).size).to eq(2)
    end

    it 'summarises with counts rather than every id' do
      described_class.log_summary([create_entry(model: 'Author', id: 1), create_entry(model: 'Author', id: 2)])

      expect(FactorySeeder.execution_logs.last[:meta]).to eq(models: { 'Author' => 2 })
    end
  end
end
