# FactorySeeder

A powerful Ruby gem that simplifies database seeding using your existing FactoryBot factories, traits, and associations.

## Features

- **Automatic Factory Detection**: Scans your FactoryBot factories automatically
- **Trait Support**: Use existing traits to create varied data
- **Association Handling**: Manage complex relationships between models
- **Web Interface**: Beautiful web UI for visual seeding with Rails Engine integration
- **CLI Interface**: Command-line tool for quick seeding
- **Custom Seeds System**: Define reusable seeds with parameter validation
- **Preview Mode**: See what data will be generated before creating it
- **Configuration**: Flexible configuration for different environments
- **Auto-reload**: Changes to custom seeds are automatically reloaded without server restart

## Installation

Add this line to your application's Gemfile:

```ruby
group :development, :test do
  gem 'factory_seeder'
end
```

Then execute:

```bash
bundle install
```

## Quick Start

### 1. Initialize FactorySeeder

```bash
bundle exec factory_seeder init
```

This creates:
- `config/initializers/factory_seeder.rb` - Configuration file
- `db/seeds_factory_seeder.rb` - Sample seeds file

### 2. List Available Factories

```bash
bundle exec factory_seeder list
```

The CLI now displays detailed information for each factory including class name, traits, associations, and key attributes - matching the web interface experience.

### 3. Generate Seeds

#### Interactive Mode
```bash
bundle exec factory_seeder generate
```

#### Direct Mode
```bash
bundle exec factory_seeder generate user --count=10 --traits=admin,vip
```

The `generate` and `preview` commands now use `config.default_count` and `config.default_strategy` when options are omitted.

#### With Custom Attributes
```bash
bundle exec factory_seeder generate user --count=5 --attributes='{"email":"admin@example.com","role":"admin"}'
```

### 4. Web Interface (Rails Engine)

Mount the engine in your Rails application routes:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount FactorySeeder::Engine => "/factory-seeder"
end
```

Then access the web interface at `http://localhost:3000/factory-seeder`

**Features:**
- Visual factory listing with detailed metadata
- Trait selection with checkboxes
- Custom attribute inputs for each factory field
- Data preview before generation
- Real-time generation
- Auto-reload: Custom seeds under `db/factory_seeds/*.rb` are automatically reloaded when the Rails engine prepares a request - no server restart needed

### 5. Standalone Web Interface

For non-Rails projects or standalone usage:

```bash
bundle exec factory_seeder web --port=4567
```

The standalone web interface calls `FactorySeeder.reload!` before each request, so file edits take effect immediately.

## Usage

### Ruby API

#### Basic Generation

```ruby
# In your seeds file
FactorySeeder.generate do |seeder|
  # Create 10 users with admin trait
  seeder.create(:user, count: 10, traits: [:admin])

  # Create posts with associations
  seeder.create_with_associations(:post, count: 5, associations: {
    author: { factory: :user, count: 1 },
    comments: { factory: :comment, count: 3 }
  })

  # Create with custom attributes
  seeder.create(:user, count: 5, attributes: {
    email: "custom@example.com",
    role: "moderator"
  })
end
```

#### Different Strategies

```ruby
# Build instead of create (useful for testing)
seeder.create(:user, count: 3, strategy: :build)
```

### Custom Seeds System

Define reusable seeds with parameter validation:

```ruby
# db/factory_seeds/users.rb
FactorySeeder.define_seed(:create_users) do |builder|
  builder
    .description("Create users with customizable options")
    .integer_param(:count, required: true, min: 1, max: 100, description: "Number of users")
    .boolean_param(:admin, required: false, default: false, description: "Create admin users")
    .symbol_param(:country, required: false, default: :fr,
                  allowed_values: [:fr, :en, :es, :de], description: "User country")
end do |count:, admin: false, country: :fr|
  traits = admin ? [:admin] : []
  count.times do
    FactoryBot.create(:user, *traits, country: country)
  end
  puts "✅ Created #{count} user(s) with country: #{country}#{admin ? ' (admin)' : ''}"
end
```

#### Parameter Types

- **Integer**: `.integer_param(:count, min: 1, max: 100)`
- **Boolean**: `.boolean_param(:admin, default: false)`
- **Symbol**: `.symbol_param(:status, allowed_values: [:active, :inactive])`
- **String**: `.string_param(:name, allowed_values: ['admin', 'user'])`
- **Array**: `.array_param(:items, default: [])`

#### Running Custom Seeds

```ruby
# Programmatically
result = FactorySeeder.run_custom_seed(:create_users, count: 10, admin: true)

# Via web interface - navigate to custom seeds section
# Via CLI - use the custom seeds commands
```

### CLI Commands

```bash
# List all factories with detailed metadata
factory_seeder list

# Generate seeds interactively
factory_seeder generate

# Generate specific factory
factory_seeder generate user --count=5 --traits=admin,vip

# Generate with custom attributes (JSON format)
factory_seeder generate user --count=3 --attributes='{"email":"test@example.com","admin":true}'

# Preview factory data
factory_seeder preview user --traits=admin

# Start standalone web interface
factory_seeder web --port=4567

# Initialize configuration
factory_seeder init

# List available custom seeds
factory_seeder seeds --list

# Run a specific custom seed
factory_seeder seeds development

# Run all custom seeds
factory_seeder seeds --all

# Preview what would be generated (dry run)
factory_seeder seeds development --dry_run
```

## Configuration

Edit `config/factory_seeder.rb`:

```ruby
FactorySeeder.configure do |config|
  # Add custom factory paths
  config.factory_paths << "spec/factories"
  config.factory_paths << "test/factories"

  # Default options
  config.default_count = 10
  config.default_strategy = :create

  # Verbose mode
  config.verbose = Rails.env.development?

  # Environment-specific settings
  config.environments = {
    development: { default_count: 50 },
    test: { default_count: 5 },
    production: { default_count: 1 }
  }
end
```

## Rails Integration

FactorySeeder integrates seamlessly with Rails through a Rails Engine:

### Features

- **Automatic Model Loading**: Models are loaded before factory analysis using `config.after_initialize`
- **Development Reloading**: In development, models are reloaded when files change via `config.to_prepare`
- **Conditional Loading**: Only forces eager loading when necessary
- **Error Handling**: Gracefully handles uninitialized constants and missing dependencies

### Troubleshooting Rails Integration

#### "uninitialized constant" errors

If you encounter errors like `NameError: uninitialized constant ModelName`, the Rails engine should handle this automatically. If issues persist:

1. Ensure all migrations are up to date: `rails db:migrate`
2. Check that models are properly defined in `app/models`
3. Enable verbose mode to see detailed loading information:

```ruby
FactorySeeder.configure do |config|
  config.verbose = true
end
```

#### Factories not detected

If factories aren't appearing:

```ruby
FactorySeeder.configure do |config|
  config.factory_paths << 'spec/factories'
  config.factory_paths << 'test/factories'
end
```

## Factory Examples

### Basic Factory

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }

    trait :admin do
      role { "admin" }
    end

    trait :vip do
      vip_status { true }
    end
  end
end
```

### Factory with Associations

```ruby
# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    association :author, factory: :user

    trait :published do
      published_at { Time.current }
    end

    trait :with_comments do
      after(:create) do |post|
        create_list(:comment, 3, post: post)
      end
    end
  end
end
```

## Advanced Usage

### Environment-Specific Seeds

```ruby
FactorySeeder.generate do |seeder|
  if Rails.env.development?
    seeder.create(:user, count: 100, traits: [:admin])
    seeder.create(:post, count: 500)
  elsif Rails.env.test?
    seeder.create(:user, count: 5)
    seeder.create(:post, count: 10)
  elsif Rails.env.production?
    seeder.create(:user, count: 1, traits: [:admin])
  end
end
```

### Complex Associations

```ruby
seeder.create_with_associations(:order, count: 10, associations: {
  customer: { factory: :user, traits: [:vip] },
  items: { factory: :product, count: 3 },
  shipping_address: { factory: :address, count: 1 }
})
```

### Using Rails Model Constants

With the Rails engine, you can safely use model constants in your custom seeds:

```ruby
FactorySeeder.define_seed(:create_orders_with_status) do |builder|
  # Rails models are automatically loaded
  order_statuses = if defined?(Order) && Order.const_defined?(:STATUSES)
    Order::STATUSES.map(&:to_sym)
  else
    [:pending, :confirmed, :completed, :cancelled]
  end

  builder
    .description("Create orders with specific status")
    .symbol_param(:status, required: true, allowed_values: order_statuses)
end do |status:, count: 1|
  count.times do
    Order.create!(status: status)
  end
end
```

## Development

### Setup

```bash
git clone https://github.com/factoryseeder/factory_seeder.git
cd factory_seeder
bundle install
```

### Testing

```bash
bundle exec rspec
```

### Building the Gem

```bash
gem build factory_seeder.gemspec
gem install factory_seeder-0.1.0.gem
```

## Architecture

### Core Components

- **FactoryScanner**: Automatically detects and analyzes FactoryBot factories
- **SeedGenerator**: Creates database records using factories and traits
- **SeedManager**: Manages custom seed definitions with parameter validation
- **Seed & SeedBuilder**: Define reusable seeds with type-safe parameters
- **CLI**: Command-line interface with interactive prompts
- **WebInterface**: Sinatra-based web UI for visual seeding
- **Engine**: Rails Engine for seamless Rails integration
- **Configuration**: Flexible configuration system

### Dependencies

- **Ruby**: >= 2.7.0
- **FactoryBot**: ~> 6.0
- **ActiveSupport**: >= 6.0
- **Thor**: ~> 1.0 (CLI)
- **Sinatra**: ~> 2.0 (Web interface)
- **Faker**: ~> 3.0 (Test data generation)
- **Zeitwerk**: ~> 2.6 (Autoloading)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Support

- Issues: [GitHub Issues](https://github.com/factoryseeder/factory_seeder/issues)
- Email: team@factoryseeder.com

## Acknowledgments

- Built on top of [FactoryBot](https://github.com/thoughtbot/factory_bot)
- CLI powered by [Thor](https://github.com/erikhuda/thor)
- Web interface built with [Sinatra](https://sinatrarb.com/)
- Autoloading with [Zeitwerk](https://github.com/fxn/zeitwerk)

---

Made with ❤️ by Wecasa
