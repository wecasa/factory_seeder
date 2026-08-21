# frozen_string_literal: true

RSpec.describe FactorySeeder::Seed do
  def build_seed(parameters: {}, &block)
    block ||= -> { :ok }
    described_class.new(:demo, description: 'A demo', parameters: parameters, &block)
  end

  describe '#initialize' do
    it 'symbolises its name and parameter keys' do
      seed = described_class.new('demo', parameters: { 'count' => { type: :integer } }) { :ok }

      expect(seed.name).to eq(:demo)
      expect(seed.parameter_names).to eq([:count])
    end

    it 'defaults its description' do
      expect(described_class.new(:demo) { :ok }.description).to eq('Seed for demo')
    end
  end

  describe '#coerce_parameters' do
    subject(:seed) do
      build_seed(parameters: {
                   count: { type: :integer },
                   admin: { type: :boolean },
                   status: { type: :symbol },
                   tags: { type: :array },
                   name: { type: :string }
                 })
    end

    it 'casts each value to its declared type' do
      coerced = seed.coerce_parameters(
        'count' => '10', 'admin' => 'true', 'status' => 'active', 'tags' => 'a, b', 'name' => 'Ada'
      )

      expect(coerced).to eq(count: 10, admin: true, status: :active, tags: %w[a b], name: 'Ada')
    end

    it 'reads the documented falsey spellings' do
      %w[false 0 no off].each do |value|
        expect(seed.coerce_parameters('admin' => value)).to eq(admin: false)
      end
    end

    it 'reads the documented truthy spellings' do
      %w[true 1 yes on].each do |value|
        expect(seed.coerce_parameters('admin' => value)).to eq(admin: true)
      end
    end

    it 'leaves an unrecognised boolean alone rather than calling it false' do
      expect(seed.coerce_parameters('admin' => 'maybe')).to eq(admin: 'maybe')
    end

    it 'passes blank values through untouched' do
      expect(seed.coerce_parameters('count' => '')).to eq(count: '')
      expect(seed.coerce_parameters('count' => nil)).to eq(count: nil)
    end

    it 'leaves an already-typed array alone' do
      expect(seed.coerce_parameters('tags' => %w[a b])).to eq(tags: %w[a b])
    end

    it 'passes undeclared keys through' do
      expect(seed.coerce_parameters('unknown' => 'value')).to eq(unknown: 'value')
    end
  end

  describe '#validate_parameters!' do
    it 'requires the parameters flagged as required' do
      seed = build_seed(parameters: { count: { type: :integer, required: true } })

      expect { seed.validate_parameters!({}) }
        .to raise_error(ArgumentError, 'Missing required parameters: count')
    end

    it 'checks the declared type' do
      seed = build_seed(parameters: { count: { type: :integer, required: true } })

      expect { seed.validate_parameters!(count: 'ten') }
        .to raise_error(ArgumentError, /must be an integer/)
    end

    it 'enforces allowed values' do
      seed = build_seed(parameters: { status: { type: :symbol, allowed_values: %i[on off] } })

      expect { seed.validate_parameters!(status: :maybe) }.to raise_error(ArgumentError, /must be one of/)
      expect { seed.validate_parameters!(status: :on) }.not_to raise_error
    end

    it 'enforces min and max' do
      seed = build_seed(parameters: { count: { type: :integer, min: 1, max: 5 } })

      expect { seed.validate_parameters!(count: 0) }.to raise_error(ArgumentError, /must be >= 1/)
      expect { seed.validate_parameters!(count: 9) }.to raise_error(ArgumentError, /must be <= 5/)
    end

    it 'ignores undeclared parameters' do
      expect { build_seed.validate_parameters!(whatever: 1) }.not_to raise_error
    end
  end

  describe '#call' do
    it 'validates before running' do
      ran = false
      seed = build_seed(parameters: { count: { type: :integer, required: true } }) { ran = true }

      expect { seed.call }.to raise_error(ArgumentError)
      expect(ran).to be(false)
    end
  end

  describe '#to_h' do
    it 'exposes the definition' do
      seed = build_seed(parameters: { count: { type: :integer } })

      expect(seed.to_h).to include(name: :demo, description: 'A demo', has_parameters: true)
    end
  end
end
