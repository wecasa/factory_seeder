#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemple d'utilisation de la nouvelle gestion des seeds personnalisés
# Ce fichier démontre comment utiliser les nouvelles fonctionnalités

require_relative 'lib/factory_seeder'

# Configuration
FactorySeeder.configure do |config|
  config.verbose = true
end

puts "🌱 Exemple d'utilisation des Seeds Personnalisés FactorySeeder"
puts '=' * 60

# 1. Définition d'un seed simple
puts "\n1. Définition d'un seed simple:"
FactorySeeder.define_seed(:hello_world, lambda { |builder|
  builder
    .description('Un seed simple pour dire bonjour')
    .string_param(:name, required: true, description: 'Nom à saluer')
    .integer_param(:count, required: false, default: 1, min: 1, max: 5, description: 'Nombre de salutations')
}) do |name:, count: 1|
  count.times do |i|
    puts "👋 Bonjour #{name} ! (#{i + 1}/#{count})"
  end
  puts "✅ Seed 'hello_world' exécuté avec succès"
end

# 2. Définition d'un seed plus complexe
puts "\n2. Définition d'un seed complexe:"
FactorySeeder.define_seed(:create_sample_data, lambda { |builder|
  builder
    .description("Créer des données d'exemple avec validation")
    .integer_param(:user_count, required: true, min: 1, max: 10, description: "Nombre d'utilisateurs")
    .boolean_param(:create_posts, required: false, default: true, description: 'Créer des posts')
    .symbol_param(:user_type, required: false, default: :regular, allowed_values: %i[regular premium
                                                                                     admin], description: "Type d'utilisateur")
    .array_param(:tags, required: false, default: %w[ruby rails], description: 'Tags à appliquer')
}) do |user_count:, create_posts: true, user_type: :regular, tags: %w[ruby rails]|
  puts "📊 Création de #{user_count} utilisateur(s) de type '#{user_type}'"
  puts "📝 Création de posts: #{create_posts ? 'Oui' : 'Non'}"
  puts "🏷️  Tags: #{tags.join(', ')}"

  # Simulation de création de données
  user_count.times do |i|
    puts "  👤 Créé utilisateur ##{i + 1} (#{user_type})"

    puts "    📄 Créé post ##{i + 1} avec tags: #{tags.join(', ')}" if create_posts
  end

  puts "✅ Seed 'create_sample_data' exécuté avec succès"
end

# 3. Test de validation
puts "\n3. Test de validation des paramètres:"
begin
  # Test avec paramètres valides
  result = FactorySeeder.run_custom_seed(:hello_world, name: 'Alice', count: 3)
  puts "✅ Exécution réussie: #{result[:message]}"
rescue StandardError => e
  puts "❌ Erreur: #{e.message}"
end

begin
  # Test avec paramètres invalides (count trop élevé)
  result = FactorySeeder.run_custom_seed(:hello_world, name: 'Bob', count: 10)
  puts "✅ Exécution réussie: #{result[:message]}"
rescue StandardError => e
  puts "❌ Erreur attendue: #{e.message}"
end

# 4. Test de validation sans exécution
puts "\n4. Test de validation sans exécution:"
is_valid = FactorySeeder.seed_manager.validate_seed(:create_sample_data,
                                                    user_count: 5,
                                                    create_posts: true,
                                                    user_type: :premium,
                                                    tags: %w[test example])
puts "Validation: #{is_valid ? '✅ Valide' : '❌ Invalide'}"

# 5. Liste des seeds disponibles
puts "\n5. Seeds disponibles:"
seeds = FactorySeeder.list_custom_seeds
seeds.each do |seed|
  puts "  🌱 #{seed.name}: #{seed.description}"
  if seed.has_parameters?
    puts "    📋 Paramètres: #{seed.parameter_names.join(', ')}"
  else
    puts '    📋 Aucun paramètre'
  end
end

# 6. Recherche de seeds
puts "\n6. Recherche de seeds contenant 'hello':"
matching_seeds = FactorySeeder.seed_manager.search('hello')
matching_seeds.each do |seed|
  puts "  🔍 Trouvé: #{seed.name} - #{seed.description}"
end

# 7. Test d'erreur de paramètre manquant
puts "\n7. Test d'erreur de paramètre manquant:"
begin
  result = FactorySeeder.run_custom_seed(:hello_world) # name manquant
  puts "✅ Exécution réussie: #{result[:message]}"
rescue StandardError => e
  puts "❌ Erreur attendue: #{e.message}"
end

# 8. Test d'erreur de type incorrect
puts "\n8. Test d'erreur de type incorrect:"
begin
  result = FactorySeeder.run_custom_seed(:hello_world, name: 'Charlie', count: 'abc') # count doit être un entier
  puts "✅ Exécution réussie: #{result[:message]}"
rescue StandardError => e
  puts "❌ Erreur attendue: #{e.message}"
end

puts "\n#{'=' * 60}"
puts '🎉 Démonstration terminée !'
puts "📖 Consultez CUSTOM_SEEDS_GUIDE.md pour plus d'informations"
