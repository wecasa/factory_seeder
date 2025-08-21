# Utilisation de FactorySeeder Engine

## Installation

1. **Ajoutez la gem à votre Gemfile :**
```ruby
gem 'factory_seeder', path: '/chemin/vers/factory_seeder'
```

2. **Installez la gem :**
```bash
bundle install
```

## Configuration

### 1. Montez l'engine dans vos routes

Dans votre `config/routes.rb` :
```ruby
Rails.application.routes.draw do
  # Montez l'engine FactorySeeder
  mount FactorySeeder::Engine => "/factory-seeder"
  
  # Vos autres routes...
end
```

### 2. Configuration optionnelle

Dans votre `config/application.rb` :
```ruby
module YourApp
  class Application < Rails::Application
    # Configuration FactorySeeder
    config.factory_seeder.verbose = Rails.env.development?
    config.factory_seeder.factory_paths = ['spec/factories', 'test/factories']
  end
end
```

## Utilisation

### Interface Web

Une fois monté, accédez à l'interface via :

- **Dashboard principal** : `http://localhost:3000/factory-seeder`
- **Détails d'une factory** : `http://localhost:3000/factory-seeder/factory/user`

### API Endpoints

L'engine expose également des endpoints API :

- `GET /factory-seeder/api/factories` - Liste toutes les factories
- `GET /factory-seeder/api/factory/:name/preview` - Prévisualise une factory
- `POST /factory-seeder/generate` - Génère des seeds

## Structure de l'Engine

```
factory_seeder/
├── app/
│   ├── controllers/
│   │   └── factory_seeder/
│   │       ├── application_controller.rb
│   │       ├── dashboard_controller.rb
│   │       ├── factory_controller.rb
│   │       └── api_controller.rb
│   └── views/
│       ├── layouts/
│       │   └── factory_seeder/
│       │       └── application.html.erb
│       └── factory_seeder/
│           ├── dashboard/
│           │   └── index.html.erb
│           └── factory/
│               └── show.html.erb
├── config/
│   └── routes.rb                    # Routes de l'engine
└── lib/
    └── factory_seeder/
        └── engine.rb                # Engine simple sans routes
```

## Fonctionnalités

- **Dashboard moderne** avec liste des factories
- **Génération de seeds** avec traits et attributs personnalisés
- **Preview** avant génération
- **API REST** pour intégration programmatique
- **Design responsive** avec animations CSS
