# Exemple d'utilisation de FactorySeeder dans votre Gemfile

## Option 1: Utilisation locale (recommandée pour le développement)

```ruby
# Gemfile
group :development, :test do
  # Utiliser la gem locale
  gem 'factory_seeder', path: '/chemin/vers/factory_seeder'
  
  # Ou utiliser la gem installée localement
  # gem 'factory_seeder', '0.1.0'
end
```

## Option 2: Utilisation depuis GitHub (si vous poussez sur GitHub)

```ruby
# Gemfile
group :development, :test do
  gem 'factory_seeder', github: 'votre-username/factory_seeder'
end
```

## Option 3: Utilisation depuis un serveur privé

```ruby
# Gemfile
group :development, :test do
  gem 'factory_seeder', '0.1.0', source: 'https://votre-serveur-gems.com'
end
```

## Installation et Configuration

### 1. Installer les dépendances
```bash
bundle install
```

### 2. Configurer FactorySeeder dans votre app Rails
```ruby
# config/initializers/factory_seeder.rb
FactorySeeder.configure do |config|
  config.verbose = Rails.env.development?
  config.factory_paths << 'spec/factories'
  config.factory_paths << 'test/factories'
end
```

### 3. Utiliser la gem

#### Interface Web
```bash
bundle exec factory_seeder web
```

#### Interface CLI
```bash
bundle exec factory_seeder list
bundle exec factory_seeder generate user --count 5
```

> `factory_seeder list` affiche désormais la classe, les traits, les associations et les attributs clés. Les commandes `generate` et `preview` utilisent `config.default_count` / `config.default_strategy` quand les options sont absentes et acceptent des JSON via `--attributes`.

## Mise à Jour

### Pour les modifications locales
```bash
# Dans le répertoire factory_seeder
gem build factory_seeder.gemspec
gem install factory_seeder-0.1.0.gem

# Dans votre app Rails
bundle update factory_seeder
```

### Pour les modifications sur GitHub
```bash
# Dans votre app Rails
bundle update factory_seeder
```
