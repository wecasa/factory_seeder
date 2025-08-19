# frozen_string_literal: true

module FactorySeeder
  class WebInterface < Sinatra::Base
    configure do
      set :public_folder, File.join(File.dirname(__FILE__), '..', '..', 'public')
      set :views, File.join(File.dirname(__FILE__), '..', '..', 'views')
      enable :reloader
      set :bind, '0.0.0.0'
    end

    get '/' do
      @factories = FactorySeeder.scan_factories
      erb :index
    end

    get '/factory/:name' do
      @factory_name = params[:name]
      @factories = FactorySeeder.scan_factories
      @factory = @factories[@factory_name]

      if @factory
        erb :factory_detail
      else
        status 404
        'Factory not found'
      end
    end

    post '/generate' do
      content_type :json

      factory_name = params[:factory]
      count = params[:count].to_i
      traits = params[:traits]

      # Parse traits if it's a string
      traits = if traits.is_a?(String)
                 traits.split(',').map(&:strip)
               elsif traits.is_a?(Array)
                 traits.flatten.map(&:strip)
               else
                 []
               end

      begin
        generator = SeedGenerator.new
        generator.create(factory_name, {
                           count: count,
                           traits: traits
                         })

        { success: true, message: "Created #{count} #{factory_name} records" }.to_json
      rescue StandardError => e
        { success: false, error: e.message }.to_json
      end
    end

    get '/api/factories' do
      content_type :json
      FactorySeeder.scan_factories.to_json
    end

    get '/api/factory/:name/preview' do
      content_type :json

      factory_name = params[:name]
      traits = params[:traits]

      # Parse traits if it's a string
      traits = if traits.is_a?(String)
                 traits.split(',').map(&:strip).map(&:to_sym)
               elsif traits.is_a?(Array)
                 traits.flatten.map(&:strip).map(&:to_sym)
               else
                 []
               end

      begin
        sample = FactoryBot.build(factory_name, *traits)

        {
          success: true,
          attributes: sample.attributes.reject { |k, _| %w[id created_at updated_at].include?(k) }
        }.to_json
      rescue StandardError => e
        { success: false, error: e.message }.to_json
      end
    end
  end
end
