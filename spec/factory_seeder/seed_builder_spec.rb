# frozen_string_literal: true

RSpec.describe FactorySeeder::SeedBuilder do
  subject(:builder) { described_class.new(:demo) }

  it 'chains its declarations' do
    expect(builder.description('text')).to be(builder)
    expect(builder.parameter(:count, type: :integer)).to be(builder)
    expect(builder.metadata(:group, 'demo')).to be(builder)
  end

  it 'builds a seed carrying the declarations' do
    seed = builder.description('text').metadata(:group, 'demo').integer_param(:count).build { :ok }

    expect(seed.description).to eq('text')
    expect(seed.metadata).to eq(group: 'demo')
    expect(seed.parameter_info(:count)).to include(type: :integer)
  end

  describe 'typed shorthands' do
    {
      string_param: :string,
      integer_param: :integer,
      boolean_param: :boolean,
      symbol_param: :symbol,
      array_param: :array
    }.each do |method_name, type|
      it "#{method_name} declares a #{type} parameter" do
        seed = builder.public_send(method_name, :value).build { :ok }

        expect(seed.parameter_info(:value)).to include(type: type)
      end
    end

    it 'forwards the parameter options' do
      seed = builder.integer_param(:count, required: true, min: 1, max: 5, description: 'How many').build { :ok }

      expect(seed.parameter_info(:count))
        .to include(required: true, min: 1, max: 5, description: 'How many')
    end
  end

  describe 'option validation' do
    it 'rejects allowed_values on an integer' do
      expect { builder.integer_param(:count, allowed_values: [1]) }
        .to raise_error(ArgumentError, /allowed_values is not valid for integer/)
    end

    it 'rejects min and max on a string' do
      expect { builder.string_param(:name, min: 1) }
        .to raise_error(ArgumentError, /min and max are not valid for string/)
    end

    it 'rejects every range option on a boolean' do
      expect { builder.boolean_param(:admin, allowed_values: [true]) }
        .to raise_error(ArgumentError, /not valid for boolean/)
    end

    it 'rejects every range option on an array' do
      expect { builder.array_param(:tags, min: 1) }
        .to raise_error(ArgumentError, /not valid for array/)
    end
  end
end
