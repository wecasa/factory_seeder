# 🌱 Seeds Personnalisés - Guide Complet

Ce guide explique comment utiliser et personnaliser les seeds dans le fichier `db/seeds_factory_seeder.rb` avec FactorySeeder.

## 📁 Structure du Fichier

Le fichier `db/seeds_factory_seeder.rb` est le point d'entrée principal pour définir vos seeds personnalisés :

```ruby
# db/seeds_factory_seeder.rb
FactorySeeder.generate do |seeder|
  # Vos seeds personnalisés ici
end
```

## 🔧 Méthodes Disponibles

### 1. Création Simple - `seeder.create`

#### Créer des enregistrements avec des traits
```ruby
# Créer 10 utilisateurs avec le trait admin
seeder.create(:user, count: 10, traits: [:admin])

# Créer avec plusieurs traits
seeder.create(:user, count: 5, traits: [:admin, :verified, :vip])
```

#### Créer avec des attributs personnalisés
```ruby
# Override des valeurs par défaut
seeder.create(:user, count: 5, attributes: {
  email: "admin@example.com",
  role: "moderator",
  status: "active"
})
```

#### Combiner traits et attributs
```ruby
seeder.create(:user, count: 3, traits: [:vip], attributes: {
  subscription_type: "premium",
  email: "vip@example.com"
})
```

### 2. Création avec Associations - `seeder.create_with_associations`

#### Association simple
```ruby
# Créer des posts avec un auteur
seeder.create_with_associations(:post, count: 25, associations: {
  author: { factory: :user, count: 1 }
})
```

#### Associations multiples
```ruby
# Créer des commandes avec client et produits
seeder.create_with_associations(:order, count: 10, associations: {
  customer: { factory: :user, traits: [:vip] },
  items: { factory: :product, count: 3 }
})
```

#### Associations imbriquées
```ruby
# Créer des articles avec commentaires et utilisateurs
seeder.create_with_associations(:blog_post, count: 15, associations: {
  author: { factory: :user, traits: [:admin] },
  comments: { 
    factory: :comment, 
    count: 5,
    associations: {
      user: { factory: :user, count: 1 }
    }
  }
})
```

### 3. Différentes Stratégies

```ruby
# Créer et sauvegarder (par défaut)
seeder.create(:user, count: 5, strategy: :create)

# Construire sans sauvegarder (utile pour les tests)
seeder.create(:user, count: 3, strategy: :build)
```

## 🌍 Seeds Environnement-Spécifiques

```ruby
FactorySeeder.generate do |seeder|
  if Rails.env.development?
    # Seeds pour le développement
    seeder.create(:user, count: 100, traits: [:admin])
    seeder.create(:post, count: 500)
    seeder.create(:comment, count: 1000)
    
  elsif Rails.env.test?
    # Seeds pour les tests (données minimales)
    seeder.create(:user, count: 5)
    seeder.create(:post, count: 10)
    seeder.create(:comment, count: 20)
    
  elsif Rails.env.production?
    # Seeds pour la production (données de base)
    seeder.create(:user, count: 1, traits: [:admin])
    seeder.create(:post, count: 5)
  end
end
```

## �� Exemples Pratiques

### E-commerce
```ruby
FactorySeeder.generate do |seeder|
  # Créer des clients
  seeder.create(:user, count: 50, traits: [:customer])
  seeder.create(:user, count: 10, traits: [:vip_customer])
  seeder.create(:user, count: 5, traits: [:admin])
  
  # Créer des produits
  seeder.create(:product, count: 100, traits: [:active])
  seeder.create(:product, count: 20, traits: [:featured])
  
  # Créer des commandes avec associations
  seeder.create_with_associations(:order, count: 25, associations: {
    customer: { factory: :user, traits: [:customer] },
    items: { factory: :order_item, count: 3, associations: {
      product: { factory: :product, count: 1 }
    }}
  })
  
  # Créer des avis
  seeder.create_with_associations(:review, count: 50, associations: {
    user: { factory: :user, count: 1 },
    product: { factory: :product, count: 1 }
  })
end
```

### Blog/Forum
```ruby
FactorySeeder.generate do |seeder|
  # Créer des utilisateurs avec différents rôles
  seeder.create(:user, count: 20, traits: [:admin])
  seeder.create(:user, count: 100, traits: [:moderator])
  seeder.create(:user, count: 500) # utilisateurs réguliers
  
  # Créer des catégories
  seeder.create(:category, count: 10)
  
  # Créer des articles avec commentaires
  seeder.create_with_associations(:article, count: 50, associations: {
    author: { factory: :user, traits: [:admin] },
    category: { factory: :category, count: 1 },
    comments: { 
      factory: :comment, 
      count: 10,
      associations: {
        user: { factory: :user, count: 1 }
      }
    }
  })
  
  # Créer des tags
  seeder.create(:tag, count: 25)
end
```

### Application de Gestion
```ruby
FactorySeeder.generate do |seeder|
  # Créer des départements
  seeder.create(:department, count: 5)
  
  # Créer des employés
  seeder.create_with_associations(:employee, count: 50, associations: {
    department: { factory: :department, count: 1 }
  })
  
  # Créer des projets
  seeder.create_with_associations(:project, count: 20, associations: {
    manager: { factory: :employee, traits: [:manager], count: 1 },
    team_members: { factory: :employee, count: 5 }
  })
  
  # Créer des tâches
  seeder.create_with_associations(:task, count: 100, associations: {
    project: { factory: :project, count: 1 },
    assignee: { factory: :employee, count: 1 }
  })
end
```

## ⚙️ Configuration Avancée

### Utilisation Directe de l'API
```ruby
# Accès direct au générateur
generator = FactorySeeder::SeedGenerator.new

# Prévisualiser avant création
preview_data = generator.preview(:user, 5, [:admin])
puts preview_data

# Créer des enregistrements
result = generator.generate(:user, 10, [:vip])
puts result[:summary]

# Obtenir un résumé
puts generator.summary
```

### Seeds Nommés
```ruby
FactorySeeder.generate do |seeder|
  # Définir un seed nommé
  seeder.define_seed(:admin_users) do |gen|
    gen.create(:user, count: 10, traits: [:admin])
  end
  
  # Définir un seed pour les données de test
  seeder.define_seed(:test_data) do |gen|
    gen.create(:user, count: 5)
    gen.create(:post, count: 10)
  end
  
  # Exécuter un seed spécifique
  seeder.run_seed(:admin_users)
  
  # Exécuter tous les seeds
  seeder.run_all_seeds
end
```

### Seeds Conditionnels
```ruby
FactorySeeder.generate do |seeder|
  # Seeds basés sur la configuration
  if FactorySeeder.configuration.create_admin_user
    seeder.create(:user, count: 1, traits: [:admin])
  end
  
  # Seeds basés sur les variables d'environnement
  if ENV['CREATE_SAMPLE_DATA'] == 'true'
    seeder.create(:user, count: 100)
    seeder.create(:post, count: 500)
  end
  
  # Seeds basés sur la base de données
  if User.count == 0
    seeder.create(:user, count: 10)
  end
end
```

## 🚀 Exécution des Seeds

### Via l'Interface Web
1. Allez sur le dashboard FactorySeeder
2. Utilisez l'interface pour générer des enregistrements
3. Les seeds seront automatiquement ajoutés au fichier

### Via la Ligne de Commande
```bash
# Initialiser FactorySeeder
factory_seeder init

# Exécuter les seeds
rails db:seed:factory_seeder

# Ou via rake
rake db:seed:factory_seeder
```

### Via Rails Console
```ruby
# Dans la console Rails
FactorySeeder.generate do |seeder|
  seeder.create(:user, count: 5, traits: [:admin])
end
```

## 🛠️ Bonnes Pratiques

### 1. Organisation par Domaine
```ruby
FactorySeeder.generate do |seeder|
  # Seeds utilisateurs
  seeder.create(:user, count: 100)
  seeder.create(:user, count: 20, traits: [:admin])
  
  # Seeds produits (après utilisateurs)
  seeder.create(:product, count: 50)
  
  # Seeds commandes (après utilisateurs et produits)
  seeder.create_with_associations(:order, count: 25, associations: {
    customer: { factory: :user, count: 1 },
    items: { factory: :product, count: 3 }
  })
end
```

### 2. Utilisation des Traits pour la Variété
```ruby
# Créer différents types d'utilisateurs
seeder.create(:user, count: 50, traits: [:admin])
seeder.create(:user, count: 50, traits: [:moderator])
seeder.create(:user, count: 50, traits: [:vip])
seeder.create(:user, count: 50) # utilisateurs réguliers
```

### 3. Test des Seeds
```ruby
# Prévisualiser avant création
preview = seeder.preview(:user, 5, [:admin])
puts preview

# Créer en mode test d'abord
seeder.create(:user, count: 1, strategy: :build, traits: [:admin])
```

### 4. Gestion des Erreurs
```ruby
FactorySeeder.generate do |seeder|
  begin
    seeder.create(:user, count: 10, traits: [:admin])
  rescue => e
    puts "Erreur lors de la création des utilisateurs: #{e.message}"
  end
end
```

## 🔍 Débogage

### Vérifier les Factories Disponibles
```ruby
# Lister toutes les factories
puts FactoryBot.factories.map(&:name)

# Vérifier les traits d'une factory
user_factory = FactoryBot.factories[:user]
puts user_factory.defined_traits.map(&:name)
```

### Prévisualiser les Données
```ruby
# Prévisualiser un enregistrement
preview = seeder.preview(:user, 1, [:admin])
puts JSON.pretty_generate(preview)
```

### Vérifier les Associations
```ruby
# Vérifier les associations d'un modèle
User.reflect_on_all_associations.each do |assoc|
  puts "#{assoc.macro} :#{assoc.name}"
end
```

## 📚 Ressources Additionnelles

- [Guide d'Installation](INSTALLATION_RAILS.md)
- [Guide d'Intégration Rails](RAILS_INTEGRATION_GUIDE.md)
- [Guide des Attributs Personnalisés](CUSTOM_ATTRIBUTES_GUIDE.md)
- [Documentation FactoryBot](https://github.com/thoughtbot/factory_bot)

---

Ce guide vous donne tous les outils nécessaires pour créer des seeds personnalisés puissants et flexibles avec FactorySeeder ! 🚀
