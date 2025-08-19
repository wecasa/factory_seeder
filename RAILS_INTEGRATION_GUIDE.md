# Guide d'intégration Rails pour FactorySeeder

## Problème résolu

L'erreur `NameError: uninitialized constant Order::Refundable` était causée par le fait que FactorySeeder tentait de construire les classes de modèles avant que toutes les dépendances soient chargées dans le contexte Rails.

## Solution implémentée

### 1. Amélioration de la gestion des erreurs

Le code a été modifié pour :
- Utiliser une approche plus sûre pour obtenir les noms de classes
- Gérer gracieusement les erreurs de chargement de modèles
- Utiliser des noms de classes inférés quand les modèles ne peuvent pas être chargés

### 2. Amélioration de l'intégration Rails

- Chargement automatique des modèles Rails avant l'analyse des factories
- Retry automatique du chargement des factories qui échouent
- Gestion robuste des erreurs de dépendances

## Utilisation dans une application Rails

### Installation

1. Ajoutez la gem à votre `Gemfile` :
```ruby
gem 'factory_seeder'
```

2. Installez la gem :
```bash
bundle install
```

### Utilisation

#### Interface web
```bash
bundle exec factory_seeder web
```

#### Interface CLI
```bash
bundle exec factory_seeder list
bundle exec factory_seeder generate user --count 5
```

### Configuration

Dans votre application Rails, vous pouvez configurer FactorySeeder :

```ruby
# config/initializers/factory_seeder.rb
FactorySeeder.configure do |config|
  config.verbose = Rails.env.development?
  config.factory_paths << 'spec/factories'
  config.factory_paths << 'test/factories'
end
```

## Résolution des problèmes courants

### 1. Erreur "uninitialized constant"

**Symptôme :** `NameError: uninitialized constant ModelName::SomeConstant`

**Cause :** Le modèle fait référence à une constante qui n'est pas chargée

**Solution :** 
- Assurez-vous que tous les modèles sont chargés avant d'utiliser FactorySeeder
- Vérifiez que les associations et enums sont correctement définis
- Utilisez le mode verbose pour voir les détails des erreurs

### 2. Factories non détectées

**Symptôme :** Aucune factory n'apparaît dans l'interface

**Cause :** Les chemins des factories ne sont pas correctement configurés

**Solution :**
```ruby
FactorySeeder.configure do |config|
  config.factory_paths << 'spec/factories'
  config.factory_paths << 'test/factories'
  config.factory_paths << 'factories'
end
```

### 3. Erreurs de chargement de modèles

**Symptôme :** Erreurs lors du chargement des modèles Rails

**Cause :** Dépendances manquantes ou ordre de chargement incorrect

**Solution :**
- Vérifiez que toutes les gems nécessaires sont installées
- Assurez-vous que les migrations sont à jour
- Utilisez `Rails.application.eager_load!` en développement

## Mode debug

Pour activer le mode verbose et voir les détails des erreurs :

```ruby
FactorySeeder.configure do |config|
  config.verbose = true
end
```

Ou via la variable d'environnement :
```bash
FACTORY_SEEDER_DEBUG=1 bundle exec factory_seeder web
```

## Tests

Pour tester l'intégration dans votre application Rails :

```bash
ruby test_rails_integration.rb
```

Ce script vérifie que :
- Les factories sont correctement détectées
- L'analyse des factories fonctionne
- Les erreurs sont gérées gracieusement

## Améliorations futures

- Support des factories avec des dépendances complexes
- Intégration avec les tests RSpec et Minitest
- Support des factories conditionnelles
- Interface web améliorée avec plus de fonctionnalités
