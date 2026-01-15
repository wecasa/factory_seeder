# Guide des Seeds Personnalisés - FactorySeeder

## Vue d'ensemble

La nouvelle gestion des seeds personnalisés de FactorySeeder offre une approche plus robuste et flexible pour créer et gérer des seeds avec validation des paramètres, métadonnées et interface utilisateur améliorée.

## Architecture

### Classes principales

1. **`Seed`** - Représente un seed avec ses paramètres, validation et métadonnées
2. **`SeedBuilder`** - Interface fluide pour construire des seeds
3. **`SeedManager`** - Gestionnaire central pour tous les seeds personnalisés

## Création d'un Seed Personnalisé

### Syntaxe de base

```ruby
FactorySeeder.define_seed(:nom_du_seed) do |builder|
  builder
    .description("Description du seed")
    .integer_param(:count, required: true, min: 1, max: 100)
    .boolean_param(:admin, default: false)
    .symbol_param(:country, allowed_values: [:fr, :en, :es])
end do |count:, admin: false, country: :fr|
  # Logique du seed
  count.times do |i|
    FactoryBot.create(:user, admin: admin, country: country)
  end
end
```

### Types de paramètres supportés

#### 1. Paramètres entiers
```ruby
.integer_param(:count, 
  required: true, 
  min: 1, 
  max: 100, 
  default: 10,
  description: "Nombre d'éléments à créer")
```

#### 2. Paramètres booléens
```ruby
.boolean_param(:admin, 
  required: false, 
  default: false,
  description: "Créer des utilisateurs admin")
```

#### 3. Paramètres symboles
```ruby
.symbol_param(:country, 
  required: false, 
  default: :fr,
  allowed_values: [:fr, :en, :es, :de],
  description: "Pays des utilisateurs")
```

#### 4. Paramètres chaînes
```ruby
.string_param(:name, 
  required: true,
  allowed_values: ['admin', 'user', 'guest'],
  description: "Type d'utilisateur")
```

#### 5. Paramètres tableaux
```ruby
.array_param(:models, 
  required: false, 
  default: ['User', 'Post'],
  description: "Modèles à traiter")
```

### Méthodes helper du SeedBuilder

```ruby
# Méthodes raccourcies pour les types courants
.string_param(:name, required: true)
.integer_param(:count, min: 1, max: 100)
.boolean_param(:enabled, default: true)
.symbol_param(:status, allowed_values: [:active, :inactive])
.array_param(:items, default: [])
```

## Exemples pratiques

### 1. Création d'utilisateurs avec options

```ruby
FactorySeeder.define_seed(:create_users) do |builder|
  builder
    .description("Créer des utilisateurs avec options personnalisables")
    .integer_param(:count, required: true, min: 1, max: 100, description: "Nombre d'utilisateurs")
    .boolean_param(:admin, required: false, default: false, description: "Créer des admins")
    .symbol_param(:country, required: false, default: :fr, allowed_values: [:fr, :en, :es, :de], description: "Pays")
    .string_param(:role, required: false, default: 'user', allowed_values: ['user', 'moderator', 'admin'], description: "Rôle")
end do |count:, admin: false, country: :fr, role: 'user'|
  traits = admin ? [:admin] : []
  count.times do |i|
    FactoryBot.create(:user, *traits, country: country, role: role)
    puts "Créé utilisateur ##{i + 1}" if FactorySeeder.configuration.verbose
  end
  puts "✅ Créé #{count} utilisateur(s) avec pays: #{country}, rôle: #{role}#{admin ? ' (admin)' : ''}"
end
```

### 2. Création de posts avec commentaires

```ruby
FactorySeeder.define_seed(:create_posts_with_comments) do |builder|
  builder
    .description("Créer des posts avec commentaires associés")
    .params(:post_count, required: true, type: integer, min: 1, max: 50, description: "Nombre de posts")
    .integer_param(:comments_per_post, required: false, default: 3, min: 0, max: 10, description: "Commentaires par post")
    .boolean_param(:published, required: false, default: true, description: "Posts publiés")
end do |post_count:, comments_per_post: 3, published: true|
  post_count.times do |i|
    author = FactoryBot.create(:user)
    
    post_attributes = { author: author }
    post_attributes[:published_at] = Time.current if published
    
    post = FactoryBot.create(:post, post_attributes)
    
    comments_per_post.times do |j|
      FactoryBot.create(:comment, post: post, author: author)
    end
    
    puts "Créé post ##{i + 1} avec #{comments_per_post} commentaires" if FactorySeeder.configuration.verbose
  end
  puts "✅ Créé #{post_count} post(s) avec #{comments_per_post} commentaire(s) chacun"
end
```

### 3. Nettoyage de données

```ruby
FactorySeeder.define_seed(:cleanup_data) do |builder|
  builder
    .description("Nettoyer les données existantes")
    .array_param(:models, required: false, default: ['User', 'Post', 'Comment'], description: "Modèles à nettoyer")
    .boolean_param(:confirm, required: true, description: "Confirmer la suppression")
end do |models: ['User', 'Post', 'Comment'], confirm: false|
  unless confirm
    raise "Nettoyage annulé - confirmation requise"
  end
  
  models.each do |model_name|
    model_class = model_name.constantize
    count = model_class.count
    model_class.destroy_all
    puts "🗑️  Supprimé #{count} #{model_name.downcase}(s)"
  end
  puts "✅ Nettoyage terminé"
end
```

## Utilisation via l'interface web

### Interface utilisateur

1. **Page d'index** - Liste tous les seeds avec leurs paramètres
2. **Page de détail** - Formulaire dynamique basé sur les paramètres définis
3. **Validation en temps réel** - Les types de champs s'adaptent aux paramètres

### Types de champs automatiques

- **Entiers** → Champ numérique avec min/max
- **Booléens** → Liste déroulante (Oui/Non)
- **Symboles avec valeurs autorisées** → Liste déroulante
- **Tableaux** → Champ texte (valeurs séparées par des virgules)
- **Chaînes** → Champ texte ou liste déroulante si valeurs autorisées

## API programmatique

### Exécution d'un seed

```ruby
# Exécution simple
result = FactorySeeder.run_custom_seed(:create_users, count: 10, admin: true)

# Vérification du résultat
if result[:success]
  puts result[:message]
else
  puts "Erreur: #{result[:error]}"
end
```

### Validation des paramètres

```ruby
# Validation sans exécution
is_valid = FactorySeeder.seed_manager.validate_seed(:create_users, count: 10, admin: true)
```

### Recherche de seeds

```ruby
# Recherche par nom ou description
seeds = FactorySeeder.seed_manager.search("user")
```

## Gestion des erreurs

### Types d'erreurs gérées

1. **Paramètres manquants** - Paramètres requis non fournis
2. **Types incorrects** - Valeurs ne correspondant pas au type attendu
3. **Valeurs hors limites** - Valeurs en dehors des min/max définis
4. **Valeurs non autorisées** - Valeurs non présentes dans allowed_values

### Messages d'erreur explicites

```ruby
# Exemple d'erreur
{
  success: false,
  seed_name: :create_users,
  error: "Parameter 'count' must be >= 1",
  message: "Seed 'create_users' failed: Parameter 'count' must be >= 1"
}
```

## Bonnes pratiques

### 1. Noms descriptifs
```ruby
# ✅ Bon
FactorySeeder.define_seed(:create_admin_users_with_posts)

# ❌ Éviter
FactorySeeder.define_seed(:seed1)
```

### 2. Descriptions claires
```ruby
builder.description("Créer des utilisateurs administrateurs avec leurs posts associés et commentaires")
```

### 3. Validation appropriée
```ruby
# Limites raisonnables
.integer_param(:count, min: 1, max: 1000)

# Valeurs autorisées explicites
.symbol_param(:status, allowed_values: [:active, :inactive, :pending])
```

### 4. Valeurs par défaut sensées
```ruby
.boolean_param(:admin, default: false)
.symbol_param(:country, default: :fr)
```

## Migration depuis l'ancien système

### Ancien système
```ruby
FactorySeeder.generate do |seeder|
  seeder.seed(:create_users) do |count: 10|
    count.times { FactoryBot.create(:user) }
  end
end
```

### Nouveau système
```ruby
FactorySeeder.define_seed(:create_users) do |builder|
  builder
    .description("Créer des utilisateurs")
    .integer_param(:count, required: true, min: 1, max: 100)
end do |count:|
  count.times { FactoryBot.create(:user) }
end
```

## Avantages de la nouvelle approche

1. **Validation robuste** - Types et contraintes automatiques
2. **Interface utilisateur dynamique** - Formulaires adaptatifs
3. **Métadonnées riches** - Descriptions, types, contraintes
4. **Gestion d'erreurs améliorée** - Messages explicites
5. **API cohérente** - Interface fluide et prévisible
6. **Extensibilité** - Facile d'ajouter de nouveaux types de paramètres
