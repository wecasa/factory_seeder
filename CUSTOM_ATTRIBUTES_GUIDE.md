# Guide des Attributs Personnalisés - FactorySeeder

## 🎯 Nouvelle Fonctionnalité

FactorySeeder supporte maintenant les **attributs personnalisés** dans l'interface web, permettant aux utilisateurs de personnaliser les valeurs des champs avant la génération des seeds.

## ✨ Fonctionnalités Ajoutées

### 1. **Interface Web Améliorée**
- Champs d'entrée pour chaque attribut de la factory
- Prévisualisation des données avec attributs personnalisés
- Validation et gestion d'erreurs robuste

### 2. **API Étendue**
- Support des attributs personnalisés dans l'API de génération
- Prévisualisation avec attributs personnalisés
- Gestion JSON et form data

### 3. **Génération Intelligente**
- Override des valeurs par défaut des factories
- Conservation des valeurs par défaut si non spécifiées
- Support des traits et attributs combinés

## 🚀 Utilisation

### Interface Web

1. **Accédez à une factory** via l'interface web
2. **Remplissez les champs d'attributs** que vous souhaitez personnaliser
3. **Laissez vides** les champs que vous voulez garder par défaut
4. **Cliquez sur "Preview Data"** pour voir le résultat
5. **Générez les seeds** avec vos valeurs personnalisées

### Exemple d'Utilisation

```javascript
// Données envoyées à l'API
{
  "factory": "user",
  "count": 5,
  "traits": "admin,vip",
  "attributes": {
    "email": "admin@company.com",
    "first_name": "John",
    "role": "super_admin"
  }
}
```

## 🔧 API Endpoints

### Génération avec Attributs Personnalisés

```http
POST /generate
Content-Type: application/json

{
  "factory": "user",
  "count": 3,
  "traits": "admin",
  "attributes": {
    "email": "custom@example.com",
    "first_name": "Jane"
  }
}
```

### Prévisualisation avec Attributs Personnalisés

```http
GET /api/factory/user/preview?traits=admin&attributes={"email":"test@example.com"}
```

## 🎨 Interface Utilisateur

### Champs d'Attributs
- **Style moderne** avec bordures et focus states
- **Labels informatifs** avec type d'attribut
- **Placeholders** explicatifs
- **Validation** en temps réel

### Prévisualisation
- **JSON formaté** pour une lecture facile
- **Valeurs finales** incluant les attributs personnalisés
- **Gestion d'erreurs** claire

## 🔍 Fonctionnalités Techniques

### 1. **Extraction d'Attributs**
```ruby
# Détection automatique des attributs de factory
factory.definition.declarations.each do |declaration|
  next if declaration.is_a?(FactoryBot::Declaration::Association)
  
  attributes << {
    name: declaration.name.to_s,
    type: declaration.class.name.demodulize.downcase
  }
end
```

### 2. **Génération avec Override**
```ruby
# Les attributs personnalisés override les valeurs par défaut
record = FactoryBot.create(factory_name, *traits, custom_attributes)
```

### 3. **Gestion des Types**
- **Dynamic** : Attributs générés dynamiquement
- **Implicit** : Attributs implicites
- **Sequence** : Attributs avec séquence
- **Association** : Associations (non modifiables)

## 🛠️ Configuration

### Activation des Attributs Personnalisés
```ruby
FactorySeeder.configure do |config|
  config.verbose = true
  # Les attributs personnalisés sont activés par défaut
end
```

### Personnalisation du Style
```css
.attributes-section {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 15px;
  background: #f9f9f9;
}

.attribute-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
}
```

## 🧪 Tests

### Test de Génération
```ruby
generator = FactorySeeder::SeedGenerator.new
result = generator.generate('user', 1, [], {
  'email' => 'custom@example.com',
  'first_name' => 'John'
})
```

### Test de Prévisualisation
```ruby
preview = generator.preview('user', 1, [], {
  'email' => 'test@example.com'
})
```

## 🎯 Cas d'Usage

### 1. **Développement Local**
- Créer des utilisateurs avec des emails spécifiques
- Tester différents rôles et permissions
- Simuler des scénarios réels

### 2. **Tests**
- Générer des données de test cohérentes
- Tester des cas limites
- Valider des contraintes métier

### 3. **Démo et Présentation**
- Créer des données réalistes pour les démonstrations
- Montrer des exemples concrets
- Faciliter les tests utilisateur

## 🔮 Améliorations Futures

### Fonctionnalités Planifiées
- **Validation des types** (email, date, etc.)
- **Suggestions intelligentes** basées sur les patterns
- **Templates d'attributs** réutilisables
- **Import/Export** de configurations d'attributs
- **Historique** des attributs utilisés

### Interface Avancée
- **Éditeur JSON** pour les objets complexes
- **Drag & Drop** pour réorganiser les attributs
- **Auto-complétion** basée sur les modèles
- **Validation en temps réel** avec feedback visuel

## 🐛 Dépannage

### Problèmes Courants

1. **Attributs non reconnus**
   - Vérifiez que l'attribut existe dans la factory
   - Assurez-vous que le nom est correct (case sensitive)

2. **Valeurs non appliquées**
   - Vérifiez le format des données
   - Assurez-vous que l'attribut n'est pas en lecture seule

3. **Erreurs de validation**
   - Vérifiez les contraintes du modèle
   - Assurez-vous que les types sont compatibles

### Debug
```ruby
# Activer le mode verbose
FactorySeeder.configure do |config|
  config.verbose = true
end
```

## 📚 Exemples Complets

### Factory User avec Attributs Personnalisés
```ruby
# Factory
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { 'user' }
  end
end

# Utilisation avec attributs personnalisés
{
  "factory": "user",
  "count": 3,
  "attributes": {
    "email": "admin@company.com",
    "first_name": "John",
    "role": "admin"
  }
}
```

Cette nouvelle fonctionnalité rend FactorySeeder beaucoup plus flexible et puissant pour la génération de données de test personnalisées ! 🚀
