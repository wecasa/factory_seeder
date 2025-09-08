# Solution Railtie pour le Chargement des Modèles Rails

## Vue d'ensemble

La solution utilise un `Rails::Engine` avec `config.after_initialize` pour s'assurer que les modèles Rails sont chargés avant que FactorySeeder ne définisse les seeds personnalisés.

## Architecture

### Railtie dans `lib/factory_seeder/engine.rb`

```ruby
module FactorySeeder
  class Engine < ::Rails::Engine
    isolate_namespace FactorySeeder

    # Chargement automatique des modèles Rails pour FactorySeeder
    config.after_initialize do
      # S'assurer que les modèles Rails sont chargés avant de définir les seeds
      if Rails.application && !Rails.application.config.eager_load
        Rails.application.eager_load!
      end
    end

    # En développement, recharger les modèles quand les fichiers changent
    if Rails.env.development?
      config.to_prepare do
        # Recharger les modèles si nécessaire
        if Rails.application && !Rails.application.config.eager_load
          Rails.application.eager_load!
        end
      end
    end
  end
end
```

## Comment ça fonctionne

### 1. **`config.after_initialize`**
- S'exécute **après** que Rails ait initialisé l'application
- Garantit que tous les composants Rails sont prêts
- Charge les modèles si `eager_load` est désactivé

### 2. **`config.to_prepare` (développement)**
- S'exécute à chaque rechargement en développement
- Permet de recharger les modèles quand les fichiers changent
- Assure la cohérence pendant le développement

### 3. **Vérification conditionnelle**
```ruby
if Rails.application && !Rails.application.config.eager_load
  Rails.application.eager_load!
end
```
- Ne force le chargement que si nécessaire
- Respecte la configuration Rails existante
- Évite les doublons de chargement

## Avantages de cette approche

### ✅ **Conforme aux conventions Rails**
- Utilise l'API officielle `Rails::Engine`
- Respecte le cycle de vie Rails
- Intégration native avec l'écosystème

### ✅ **Automatique et transparent**
- Aucune configuration manuelle requise
- Fonctionne dans tous les environnements
- Pas d'intervention de l'utilisateur

### ✅ **Robuste et performant**
- Vérifie la configuration avant d'agir
- Évite les chargements inutiles
- Gère les cas d'erreur gracieusement

### ✅ **Compatible avec tous les contextes**
- Console Rails
- Fichiers de seeds
- Tests
- Serveur web

## Utilisation

### Dans vos seeds personnalisés

```ruby
# Les modèles Rails sont automatiquement disponibles !
FactorySeeder.define_seed(:create_orders_with_status, ->(builder) {
  # Les modèles Rails sont maintenant chargés par le Railtie
  order_statuses = if defined?(Order) && Order.const_defined?(:STATUSES)
    Order::STATUSES.map(&:to_sym)  # ✅ Fonctionne maintenant !
  else
    [:pending, :confirmed, :completed, :cancelled]  # Fallback
  end

  builder
    .description("Create orders with specific status")
    .symbol_param(:status, 
      required: true, 
      allowed_values: order_statuses,
      description: "Order status to create")
}) do |status:, count: 1|
  # Logique du seed avec modèles Rails disponibles
  count.times do |i|
    if defined?(Order)
      order = Order.create!(status: status)
      puts "✅ Order ##{i + 1} created: #{order.id}"
    end
  end
end
```

### Exemples avec différents modèles

```ruby
# Utilisation des constantes de modèle
FactorySeeder.define_seed(:create_users_with_roles, ->(builder) {
  user_roles = if defined?(User) && User.const_defined?(:ROLES)
    User::ROLES.map(&:to_sym)
  else
    [:user, :admin, :moderator]
  end

  builder
    .symbol_param(:role, allowed_values: user_roles)
}) do |role:|
  # Logique avec User::ROLES disponible
end

# Utilisation des enums Rails
FactorySeeder.define_seed(:create_products_with_categories, ->(builder) {
  categories = if defined?(Product) && Product.respond_to?(:categories)
    Product.categories.keys.map(&:to_sym)
  else
    [:electronics, :clothing, :books]
  end

  builder
    .symbol_param(:category, allowed_values: categories)
}) do |category:|
  # Logique avec Product.categories disponible
end
```

## Configuration Rails

### Environnements avec `eager_load = true`
```ruby
# config/environments/production.rb
config.eager_load = true  # Les modèles sont déjà chargés
```

### Environnements avec `eager_load = false`
```ruby
# config/environments/development.rb
config.eager_load = false  # Le Railtie force le chargement
```

## Dépannage

### Problème: Modèles toujours non chargés

**Vérifications:**
1. Le Railtie est-il chargé ?
```ruby
# Dans la console Rails
FactorySeeder::Engine
```

2. L'application Rails est-elle initialisée ?
```ruby
Rails.application.initialized?
```

3. Les modèles existent-ils ?
```ruby
defined?(Order)  # Devrait retourner "constant"
```

### Problème: Performance en développement

**Solution:** Le Railtie ne charge que si nécessaire :
```ruby
if Rails.application && !Rails.application.config.eager_load
  Rails.application.eager_load!  # Seulement si pas déjà fait
end
```

## Comparaison avec d'autres solutions

### ❌ **Initializer manuel**
```ruby
# config/initializers/factory_seeder.rb
Rails.application.config.after_initialize do
  Rails.application.eager_load!
end
```
**Problèmes:** Pas dans la gem, configuration manuelle

### ❌ **Chargement dans define_seed**
```ruby
def define_seed(name, &block)
  Rails.application.eager_load!  # À chaque appel
  # ...
end
```
**Problèmes:** Performance, chargement répétitif

### ✅ **Railtie avec config.after_initialize**
```ruby
class Engine < ::Rails::Engine
  config.after_initialize do
    # Chargement intelligent et conditionnel
  end
end
```
**Avantages:** Automatique, performant, conforme Rails

## Conclusion

La solution Railtie est la **meilleure approche** car elle :

- 🎯 **Résout le problème** à la source
- 🚀 **Respecte les conventions** Rails
- ⚡ **Optimise les performances** avec des vérifications conditionnelles
- 🔄 **Gère le rechargement** en développement
- 🛡️ **Évite les erreurs** avec des fallbacks

Cette solution permet d'utiliser les modèles Rails naturellement dans FactorySeeder, comme dans n'importe quelle autre partie de l'application Rails.
