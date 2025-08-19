# frozen_string_literal: true

# Initializer pour FactorySeeder
# Permet d'utiliser FactorySeeder directement avec bundle exec factory_seeder

# Charger FactorySeeder seulement si la gem est installée
begin
  require 'factory_seeder'

  # Configuration automatique de FactorySeeder
  FactorySeeder.configure do |config|
    # Ajouter les chemins des factories Rails
    config.factory_paths << 'spec/factories' if Dir.exist?('spec/factories')
    config.factory_paths << 'test/factories' if Dir.exist?('test/factories')

    # Activer le mode verbose en développement
    config.verbose = Rails.env.development?
  end

  puts "✅ FactorySeeder initialisé avec #{FactorySeeder.list_factory_names.count} factories" if Rails.env.development?
rescue LoadError => e
  puts "⚠️  FactorySeeder non installé: #{e.message}" if Rails.env.development?
end
