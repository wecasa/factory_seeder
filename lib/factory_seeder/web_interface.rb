# frozen_string_literal: true

module FactorySeeder
  class WebInterface < Sinatra::Base
    configure do
      set :public_folder, File.join(File.dirname(__FILE__), '..', '..', 'public')
      set :views, File.join(File.dirname(__FILE__), '..', '..', 'views')
      enable :reloader
      set :bind, '0.0.0.0'
    end

    before do
      FactorySeeder.reload!
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

      # Parse JSON body if present
      if request.content_type == 'application/json'
        data = JSON.parse(request.body.read)
        factory_name = data['factory']
        count = data['count'].to_i
        traits = data['traits']
        attributes = data['attributes'] || {}
      else
        factory_name = params[:factory]
        count = params[:count].to_i
        traits = params[:traits]
        attributes = params[:attributes] || {}
      end

      # Parse traits if it's a string
      traits = if traits.is_a?(String) && !traits.empty?
                 traits.split(',').map(&:strip)
               elsif traits.is_a?(Array)
                 traits.flatten.map(&:strip)
               else
                 []
               end

      begin
        generator = SeedGenerator.new
        result = generator.generate(factory_name, count, traits, attributes)

        if result[:errors].any?
          { success: false, error: result[:errors].join(', ') }.to_json
        else
          { success: true, message: "Created #{result[:count]} #{factory_name} records" }.to_json
        end
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
      attributes = params[:attributes] || {}

      # Parse traits if it's a string
      traits = if traits.is_a?(String)
                 traits.split(',').map(&:strip).map(&:to_sym)
               elsif traits.is_a?(Array)
                 traits.flatten.map(&:strip).map(&:to_sym)
               else
                 []
               end

      # Parse attributes if it's a string
      if attributes.is_a?(String) && !attributes.empty?
        begin
          attributes = JSON.parse(attributes)
        rescue JSON::ParserError
          attributes = {}
        end
      end

      begin
        sample = FactoryBot.build(factory_name, *traits, attributes)

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
