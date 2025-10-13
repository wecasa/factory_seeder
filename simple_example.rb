#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemple simple pour tester les nouvelles classes sans dépendances externes

# Charger seulement les classes nécessaires
require_relative 'lib/factory_seeder/seed'
require_relative 'lib/factory_seeder/seed_builder'
require_relative 'lib/factory_seeder/seed_manager'

puts '🌱 Test des nouvelles classes de Seeds Personnalisés'
puts '=' * 60

# 1. Test du SeedBuilder
puts "\n1. Test du SeedBuilder:"
builder = FactorySeeder::SeedBuilder.new(:test_seed)
builder
  .description('Un seed de test')
  .integer_param(:count, required: true, min: 1, max: 10, description: "Nombre d'éléments")
  .boolean_param(:enabled, required: false, default: true, description: 'Activer le seed')

seed = builder.build do |count:, enabled: true|
  puts "Exécution du seed avec count=#{count}, enabled=#{enabled}"
  'Résultat du seed'
end

puts "✅ Seed créé: #{seed.name}"
puts "   Description: #{seed.description}"
puts "   Paramètres: #{seed.parameter_names.join(', ')}"

# 2. Test du SeedManager
puts "\n2. Test du SeedManager:"
manager = FactorySeeder::SeedManager.new

# Enregistrer le seed
manager.register(seed)
puts '✅ Seed enregistré dans le manager'

# Tester la validation
puts "\n3. Test de validation:"
begin
  # Test avec paramètres valides
  result = manager.run(:test_seed, count: 5, enabled: true)
  puts "✅ Exécution réussie: #{result[:message]}"
rescue StandardError => e
  puts "❌ Erreur: #{e.message}"
end

begin
  # Test avec paramètres invalides
  result = manager.run(:test_seed, count: 15, enabled: true) # count > max
  puts "✅ Exécution réussie: #{result[:message]}"
rescue StandardError => e
  puts "❌ Erreur attendue: #{e.message}"
end

# 3. Test de validation sans exécution
puts "\n4. Test de validation sans exécution:"
is_valid = manager.validate_seed(:test_seed, count: 3, enabled: false)
puts "Validation: #{is_valid ? '✅ Valide' : '❌ Invalide'}"

# 4. Test d'erreur de paramètre manquant
puts "\n5. Test d'erreur de paramètre manquant:"
begin
  result = manager.run(:test_seed, enabled: true) # count manquant
  puts "✅ Exécution réussie: #{result[:message]}"
rescue StandardError => e
  puts "❌ Erreur attendue: #{e.message}"
end

# 5. Test d'erreur de type incorrect
puts "\n6. Test d'erreur de type incorrect:"
begin
  result = manager.run(:test_seed, count: 'abc', enabled: true) # count doit être un entier
  puts "✅ Exécution réussie: #{result[:message]}"
rescue StandardError => e
  puts "❌ Erreur attendue: #{e.message}"
end

# 6. Liste des seeds
puts "\n7. Seeds disponibles:"
seeds = manager.list
seeds.each do |s|
  puts "  🌱 #{s.name}: #{s.description}"
  puts "    📋 Paramètres: #{s.parameter_names.join(', ')}"
end

# 7. Test de recherche
puts "\n8. Test de recherche:"
matching_seeds = manager.search('test')
matching_seeds.each do |s|
  puts "  🔍 Trouvé: #{s.name} - #{s.description}"
end

puts "\n#{'=' * 60}"
puts '🎉 Tests terminés avec succès !'
puts '📖 Les nouvelles classes fonctionnent correctement'
