# FactorySeeder 🏭

A powerful gem that simplifies database seeding using your existing FactoryBot factories, traits, and associations.

## ✨ Features

- **🔍 Automatic Factory Detection**: Scans your FactoryBot factories automatically
- **🎨 Trait Support**: Use existing traits to create varied data
- **🔗 Association Handling**: Manage complex relationships between models
- **🖥️ Web Interface**: Beautiful web UI for visual seeding
- **💻 CLI Interface**: Command-line tool for quick seeding
- **📊 Preview Mode**: See what data will be generated before creating it
- **⚙️ Configuration**: Flexible configuration for different environments

## 🚀 Installation

Add this line to your application's Gemfile:

```ruby
gem 'factory_seeder'
```

And then execute:

```bash
bundle install
```

## 🎯 Quick Start

### 1. Initialize FactorySeeder

```bash
factory_seeder init
```

This creates:
- `config/factory_seeder.rb` - Configuration file
- `db/seeds_factory_seeder.rb` - Sample seeds file

### 2. List Available Factories

```bash
factory_seeder list
```

### 3. Generate Seeds

#### Interactive Mode
```bash
factory_seeder generate
```

#### Direct Mode
```bash
factory_seeder generate user --count=10 --traits=admin,vip
```

#### Web Interface
```bash
factory_seeder web
```

## 📖 Usage

### Ruby API

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
end
```

### CLI Commands

```bash
# List all factories
factory_seeder list

# Generate seeds interactively
factory_seeder generate

# Generate specific factory
factory_seeder generate user --count=5 --traits=admin,vip

# Preview factory data
factory_seeder preview user --traits=admin

# Start web interface
factory_seeder web --port=3000

# Initialize configuration
factory_seeder init
```

### Web Interface

Start the web interface and navigate to `http://localhost:4567`:

```bash
factory_seeder web
```

Features:
- 📋 Visual factory listing
- 🎨 Trait selection with checkboxes
- 🔢 Count configuration
- 👀 Data preview
- ⚡ Real-time generation

## ⚙️ Configuration

Edit `config/factory_seeder.rb`:

```ruby
FactorySeeder.configure do |config|
  # Add custom factory paths
  config.factory_paths << "custom/factories"
  
  # Default options
  config.default_count = 1
  config.default_strategy = :create
  
  # Environment-specific settings
  config.environments = {
    development: { default_count: 10 },
    test: { default_count: 5 },
    production: { default_count: 1 }
  }
end
```

## 🏗️ Factory Examples

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

## 🔧 Advanced Usage

### Custom Attributes
```ruby
seeder.create(:user, count: 5, attributes: {
  email: "custom@example.com",
  role: "moderator"
})
```

### Different Strategies
```ruby
seeder.create(:user, count: 3, strategy: :build)  # build instead of create
```

### Complex Associations
```ruby
seeder.create_with_associations(:order, count: 2, associations: {
  customer: { factory: :user, traits: [:vip] },
  items: { factory: :product, count: 3 }
})
```

## 🛠️ Development

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
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🆘 Support

- 📧 Email: support@factoryseeder.com
- 🐛 Issues: [GitHub Issues](https://github.com/factoryseeder/factory_seeder/issues)
- 📖 Documentation: [Wiki](https://github.com/factoryseeder/factory_seeder/wiki)

## 🙏 Acknowledgments

- Built on top of [FactoryBot](https://github.com/thoughtbot/factory_bot)
- CLI powered by [Thor](https://github.com/erikhuda/thor)
- Web interface built with [Sinatra](https://sinatrarb.com/)

---

Made with ❤️ by the FactorySeeder team
