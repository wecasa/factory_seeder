# Installation FactorySeeder dans Rails 🚀

## 📦 **1. Ajouter la gem à ton Gemfile**

```ruby
# Gemfile
group :development, :test do
  # ... autres gems ...
  gem 'factory_seeder', path: '/chemin/vers/factory_seeder'
end
```

**Ou si tu veux l'installer depuis le fichier .gem :**

```ruby
# Gemfile
group :development, :test do
  # ... autres gems ...
  gem 'factory_seeder', '0.1.0'
end
```

## 🔧 **2. Installer les dépendances**

```bash
# Installer la gem
bundle install

# Vérifier que la gem est installée
bundle list | grep factory_seeder
```

## 🎯 **3. Initialiser FactorySeeder**

```bash
# Créer les fichiers de configuration
bundle exec factory_seeder init
```

Cela crée :
- `config/factory_seeder.rb` - Configuration
- `db/seeds_factory_seeder.rb` - Seeds personnalisés

## 🏗️ **4. Configurer FactorySeeder**

Éditer `config/factory_seeder.rb` :

```ruby
FactorySeeder.configure do |config|
  # Chemins personnalisés pour tes factories
  config.factory_paths << "spec/factories"
  config.factory_paths << "test/factories"
  
  # Paramètres par défaut
  config.default_count = 10
  config.default_strategy = :create
  
  # Configuration par environnement
  config.environments = {
    development: { default_count: 50 },
    test: { default_count: 10 },
    staging: { default_count: 100 },
    production: { default_count: 1 }
  }
end
```

## 🧪 **5. Tester l'installation**

### Test basique
```bash
# Lister tes factories
bundle exec factory_seeder list

# Prévisualiser une factory
bundle exec factory_seeder preview user --traits=admin

# Générer des seeds
bundle exec factory_seeder generate user --count=5 --traits=admin,vip
```

### Test avec tes modèles Rails
```bash
# Dans la console Rails
rails console

# Tester l'API Ruby
FactorySeeder.generate do |seeder|
  seeder.create(:user, count: 10, traits: [:admin])
  seeder.create(:post, count: 20, traits: [:published])
end
```

## 🌐 **6. Tester l'interface web**

```bash
# Démarrer l'interface web
bundle exec factory_seeder web --port=3001

# Ouvrir dans le navigateur
open http://localhost:3001
```

## 📝 **7. Intégrer dans tes seeds**

Éditer `db/seeds.rb` :

```ruby
# db/seeds.rb
require_relative 'seeds_factory_seeder'

# Seeds existants...
puts "Creating users..."
User.create!(email: 'admin@example.com', role: 'admin')

# Seeds avec FactorySeeder
puts "Creating test data with FactorySeeder..."
load Rails.root.join('db', 'seeds_factory_seeder.rb')
```

Ou utiliser directement :

```ruby
# db/seeds.rb
FactorySeeder.generate do |seeder|
  # Créer des utilisateurs
  seeder.create(:user, count: 20, traits: [:admin])
  seeder.create(:user, count: 50, traits: [:vip])
  
  # Créer des posts avec associations
  seeder.create_with_associations(:post, count: 30, associations: {
    author: { factory: :user, count: 1 }
  })
  
  # Créer des commentaires
  seeder.create(:comment, count: 100, traits: [:approved])
end
```

## 🔄 **8. Créer des seeds spécifiques**

```bash
# Créer un fichier de seeds personnalisé
cat > db/seeds_development.rb << 'EOF'
FactorySeeder.generate do |seeder|
  # Seeds pour le développement
  seeder.create(:user, count: 100, traits: [:admin])
  seeder.create(:post, count: 500, traits: [:published])
  seeder.create(:comment, count: 1000, traits: [:approved])
end
EOF

# Exécuter les seeds
rails db:seed:development
```

## 🎨 **9. Utiliser avec des traits personnalisés**

Si tu as des traits complexes dans tes factories :

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    
    trait :admin do
      role { 'admin' }
      admin_level { 'super' }
    end
    
    trait :vip do
      vip_status { true }
      vip_expires_at { 1.year.from_now }
    end
    
    trait :with_posts do
      after(:create) do |user|
        create_list(:post, rand(1..5), author: user)
      end
    end
  end
end
```

Puis utiliser :

```bash
# Générer des admins VIP avec posts
bundle exec factory_seeder generate user --count=10 --traits=admin,vip,with_posts
```

## 🚨 **10. Gestion des erreurs courantes**

### Erreur "Factory not found"
```bash
# Vérifier les chemins des factories
bundle exec factory_seeder list

# Ajouter des chemins personnalisés dans config/factory_seeder.rb
config.factory_paths << "app/factories"
```

### Erreur de base de données
```bash
# S'assurer que la DB est migrée
rails db:migrate

# Vérifier les validations des modèles
rails console
User.new.valid? # Devrait retourner true ou false, pas d'erreur
```

### Erreur de dépendances
```bash
# Réinstaller les dépendances
bundle install

# Vérifier les versions
bundle list | grep factory_bot
bundle list | grep faker
```

## 🎯 **11. Commandes utiles pour le développement**

```bash
# Mode interactif pour tester
bundle exec factory_seeder generate

# Preview avant création
bundle exec factory_seeder preview post --traits=published,featured

# Génération rapide
bundle exec factory_seeder generate comment --count=50 --traits=approved

# Interface web pour exploration
bundle exec factory_seeder web --port=3001
```

## 📊 **12. Monitoring et logs**

```bash
# Voir les logs de génération
RAILS_LOG_LEVEL=debug bundle exec factory_seeder generate user --count=100

# Profiler les performances
time bundle exec factory_seeder generate post --count=1000
```

## 🎉 **13. Validation finale**

```bash
# Test complet
echo "=== Test FactorySeeder ==="
bundle exec factory_seeder list
bundle exec factory_seeder preview user --traits=admin
bundle exec factory_seeder generate user --count=5 --traits=admin
echo "=== Test terminé ==="
```

**🎯 FactorySeeder est maintenant intégré à ton application Rails !**
