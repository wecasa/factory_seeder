# frozen_string_literal: true

RSpec.describe FactorySeeder::CLI do
  def run(*args)
    capture_stdout { described_class.start(args) }
  end

  describe 'the exposed commands' do
    it 'lists only the supported ones' do
      expect(described_class.all_commands.keys).to match_array(%w[generate init list preview seeds help])
    end

    it 'no longer exposes the standalone web server' do
      expect(described_class.all_commands.keys).not_to include('web')
    end

    it 'does not expose the private helpers as commands' do
      expect(described_class.all_commands.keys)
        .not_to include('run_specific_seed', 'run_custom_seed', 'print_created_records')
    end
  end

  describe 'seeds options' do
    subject(:options) { described_class.commands['seeds'].options.keys }

    it 'offers listing and parameters' do
      expect(options).to include(:list, :params)
    end

    it 'no longer offers running every seed at once' do
      expect(options).not_to include(:all)
    end

    it 'no longer offers a dry run it never honoured' do
      expect(options).not_to include(:dry_run)
    end
  end

  describe 'generate' do
    it 'creates the requested number of records' do
      output = run('generate', 'fs_author', '--count=2')

      expect(output).to include('Generated 2 fs_author records')
    end

    it 'refuses an unknown factory' do
      expect(run('generate', 'does_not_exist')).to include("Factory 'does_not_exist' not found")
    end
  end

  describe 'preview' do
    it 'prints the built attributes without persisting' do
      output = run('preview', 'fs_author', '--count=1')

      expect(output).to include('Preview for fs_author')
      expect(TestModels::Author.sequence).to eq(0)
    end

    it 'refuses an unknown factory' do
      expect(run('preview', 'does_not_exist')).to include("Factory 'does_not_exist' not found")
    end
  end

  describe 'list' do
    it 'prints the registered factories with their metadata' do
      output = run('list')

      expect(output).to include('fs_author', 'Traits:', 'Associations:', 'Attributes:')
    end

    it 'names the traits a factory declares' do
      expect(run('list')).to match(/fs_traited.*\n\s*Traits: famous/)
    end

    it 'names the associations a factory declares' do
      expect(run('list')).to match(/fs_article.*\n\s*Traits:.*\n\s*Associations: author/)
    end
  end

  describe 'seeds' do
    around do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) { example.run }
      end
    end

    def write_custom_seed(body)
      FileUtils.mkdir_p('db/factory_seeds')
      File.write('db/factory_seeds/demo.rb', body)
    end

    it 'explains what is missing when there is no seed at all' do
      output = run('seeds', '--list')

      expect(output).to include('No seeds defined in db/factory_seeds/')
    end

    it 'lists the custom seeds declared in db/factory_seeds' do
      write_custom_seed(<<~RUBY)
        FactorySeeder.define_seed(:demo, ->(b) { b.description('A demo seed').integer_param(:count) }) { :ok }
      RUBY

      output = run('seeds', '--list')

      expect(output).to include('Available seeds from db/factory_seeds/', 'demo — A demo seed', 'params: count')
    end

    it 'runs a custom seed and reports what it created' do
      write_custom_seed(<<~RUBY)
        FactorySeeder.define_seed(:demo) { FactoryBot.create(:fs_author) }
      RUBY

      output = run('seeds', 'demo')

      expect(output).to include("Seed 'demo' executed successfully")
    end

    it 'coerces the parameters it is given' do
      write_custom_seed(<<~RUBY)
        FactorySeeder.define_seed(:demo, ->(b) { b.integer_param(:count, required: true) }) do |count:|
          count.times { FactoryBot.create(:fs_author) }
        end
      RUBY

      output = run('seeds', 'demo', '--params', 'count:3')

      expect(output).to include("Seed 'demo' executed successfully")
    end

    it 'reports a failing seed without raising' do
      write_custom_seed(<<~RUBY)
        FactorySeeder.define_seed(:demo) { raise 'kaboom' }
      RUBY

      output = run('seeds', 'demo')

      expect(output).to include("Seed 'demo' failed", 'kaboom')
    end

    it 'does not drop seeds registered outside db/factory_seeds' do
      write_custom_seed("FactorySeeder.define_seed(:from_dir) { :ok }\n")
      FactorySeeder.define_seed(:from_initializer) { FactoryBot.create(:fs_author) }

      output = run('seeds', 'from_initializer')

      expect(output).to include("Seed 'from_initializer' executed successfully")
    end

    it 'asks for a name when given none' do
      write_custom_seed("FactorySeeder.define_seed(:demo) { :ok }\n")

      expect(run('seeds')).to include('Please specify a seed name')
    end

    it 'reports an unknown seed name' do
      write_custom_seed("FactorySeeder.define_seed(:demo) { :ok }\n")

      expect(run('seeds', 'missing')).to include("Seed 'missing' not found")
    end
  end
end
