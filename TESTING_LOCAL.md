# Guide de Test Local - FactorySeeder 🧪

Ce guide te montre comment tester toutes les fonctionnalités de FactorySeeder en local.

## 🏗️ **Prérequis**

```bash
# Installer les dépendances
bundle install

# S'assurer que l'exécutable est disponible
chmod +x bin/factory_seeder
```

## 🧪 **Environnement de Test**

Nous avons créé un environnement de test simulé avec :
- Modèles Ruby simulant ActiveRecord (User, Post, Comment)
- Factories FactoryBot avec traits et associations
- Données de test réalistes avec Faker

```bash
# Charger l'environnement de test
RUBYOPT="-r ./test_environment.rb"
```

## 📋 **Tests à Effectuer**

### 1. **Test CLI - Liste des Factories**

```bash
RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder list
```

**Résultat attendu :**
- Liste des 3 factories (user, post, comment)
- Affichage des traits disponibles
- Affichage des associations

### 2. **Test CLI - Prévisualisation**

```bash
# Prévisualisation simple
RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder preview user

# Prévisualisation avec traits
RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder preview user --traits=admin,vip
```

**Résultat attendu :**
- Affichage des informations de la factory
- Exemple d'attributs générés
- Application correcte des traits

### 3. **Test CLI - Génération Directe**

```bash
# Génération simple
RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder generate user --count=3

# Génération avec traits
RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder generate post --count=2 --traits=published,featured

# Génération avec traits multiples
RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder generate comment --count=5 --traits=approved
```

**Résultat attendu :**
- Messages de progression avec points
- Confirmation de création
- Résumé final

### 4. **Test CLI - Mode Interactif**

```bash
# Mode interactif simulé
echo -e "2\npublished\n3\n" | RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder generate
```

**Résultat attendu :**
- Menu de sélection des factories
- Sélection des traits disponibles
- Création des enregistrements

### 5. **Test CLI - Initialisation**

```bash
RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder init
```

**Résultat attendu :**
- Création de `config/factory_seeder.rb`
- Création de `db/seeds_factory_seeder.rb`
- Messages de confirmation

### 6. **Test Interface Web**

```bash
# Démarrer le serveur web
RUBYOPT="-r ./test_environment.rb" ./bin/factory_seeder web --port=4567 &

# Attendre le démarrage
sleep 3
```

**Tests API REST :**

```bash
# Test de la page principale
curl -s http://localhost:4567 | head -10

# Test API - Liste des factories
curl -s "http://localhost:4567/api/factories" | head -5

# Test API - Prévisualisation
curl -s "http://localhost:4567/api/factory/user/preview?traits=admin,vip"

# Test API - Génération
curl -X POST "http://localhost:4567/generate" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "factory=user&count=3&traits=admin,vip"
```

**Résultat attendu :**
- Page web fonctionnelle
- API JSON qui répond correctement
- Génération réussie via API

### 7. **Test Ruby API**

```bash
# Exécuter le script de démonstration
ruby demo.rb
```

**Résultat attendu :**
- Listing des factories
- Prévisualisation réussie
- Génération avec différents patterns
- Résumé des opérations

## 🔧 **Tests de l'API Ruby**

Créer un fichier `test_api.rb` :

```ruby
require_relative 'test_environment'

# Test de l'API directe
FactorySeeder.generate do |seeder|
  puts "=== Test API Ruby ==="
  
  # Test basique
  seeder.create(:user, count: 2, traits: [:admin])
  
  # Test avec associations
  seeder.create_with_associations(:post, count: 1, associations: {
    author: { factory: :user, count: 1 }
  })
  
  # Afficher le résumé
  seeder.summary
end
```

## 🚀 **Validation Finale**

### Checklist des Fonctionnalités ✅

- [ ] **Scan des factories** : Détection automatique
- [ ] **CLI list** : Affichage des factories avec traits/associations
- [ ] **CLI preview** : Prévisualisation avec traits
- [ ] **CLI generate** : Génération directe avec options
- [ ] **CLI interactif** : Mode de sélection interactive
- [ ] **CLI init** : Initialisation des fichiers de config
- [ ] **Web UI** : Interface graphique fonctionnelle
- [ ] **Web API** : Endpoints REST opérationnels
- [ ] **Ruby API** : Interface programmatique
- [ ] **Configuration** : Paramétrage par environnement
- [ ] **Associations** : Création de modèles liés
- [ ] **Traits multiples** : Application de plusieurs traits
- [ ] **Gestion d'erreurs** : Messages d'erreur appropriés

### Performance et Qualité

```bash
# Vérifier que la gem se construit correctement
gem build factory_seeder.gemspec

# Tester l'installation locale
gem install factory_seeder-0.1.0.gem

# Vérifier les dépendances
bundle check
```

## 🐛 **Résolution de Problèmes**

### Problèmes Courants

1. **Erreur "Factory not found"**
   - Vérifier que `test_environment.rb` est chargé
   - S'assurer que les factories sont dans `spec/factories/`

2. **Erreur webrick**
   - Dépendance ajoutée dans `gemspec`
   - Redémarrer le serveur web

3. **Erreur de parsing des traits**
   - Correction implémentée dans CLI et API web
   - Utiliser des virgules pour séparer les traits

4. **API web ne répond pas**
   - Vérifier que le serveur est démarré
   - Tester avec `curl` d'abord

## 📊 **Métriques de Réussite**

Le test est réussi si :
- ✅ Tous les tests CLI passent sans erreur
- ✅ L'interface web fonctionne et répond aux requêtes
- ✅ L'API REST génère des données correctement
- ✅ Le script de démonstration s'exécute complètement
- ✅ La gem se construit sans erreur critique

---

**🎉 Félicitations ! Si tous ces tests passent, FactorySeeder est prêt pour la production !**
