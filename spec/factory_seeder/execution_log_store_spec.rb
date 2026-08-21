# frozen_string_literal: true

RSpec.describe FactorySeeder::ExecutionLogStore do
  let(:logs) { [{ 'message' => 'hello', 'level' => 'info' }] }
  let(:records) { [{ 'model' => 'Author', 'id' => 1, 'label' => 'Ada' }] }

  describe '.store and .retrieve' do
    it 'round-trips the logs, records and flash' do
      id = described_class.store(logs, records: records, flash_type: :success, flash_message: 'done')

      expect(described_class.retrieve(id)).to include(
        logs: logs, records: records, flash_type: :success, flash_message: 'done'
      )
    end

    it 'defaults the records to an empty list' do
      id = described_class.store(logs)

      expect(described_class.retrieve(id)[:records]).to eq([])
    end

    it 'consumes the entry, so it can only be read once' do
      id = described_class.store(logs)

      expect(described_class.retrieve(id)).not_to be_nil
      expect(described_class.retrieve(id)).to be_nil
    end

    it 'returns nil for an unknown or blank id' do
      expect(described_class.retrieve('nope')).to be_nil
      expect(described_class.retrieve(nil)).to be_nil
      expect(described_class.retrieve('')).to be_nil
    end

    it 'hands out distinct ids' do
      expect(described_class.store(logs)).not_to eq(described_class.store(logs))
    end
  end

  describe 'expiry' do
    it 'drops entries older than the expiry window' do
      id = described_class.store(logs)

      allow(Time).to receive(:now).and_return(Time.now + described_class::EXPIRY_TIME + 1)

      expect(described_class.retrieve(id)).to be_nil
    end
  end
end
