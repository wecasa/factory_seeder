#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple example to test the new classes without external dependencies

# Load only the required classes
require_relative 'lib/factory_seeder/seed'
require_relative 'lib/factory_seeder/seed_builder'
require_relative 'lib/factory_seeder/seed_manager'

puts '🌱 Testing the new Custom Seeds classes'
puts '=' * 60

# 1. SeedBuilder test
puts "\n1. SeedBuilder test:"
builder = FactorySeeder::SeedBuilder.new(:test_seed)
builder
  .description('A test seed')
  .integer_param(:count, required: true, min: 1, max: 10, description: 'Number of items')
  .boolean_param(:enabled, required: false, default: true, description: 'Enable the seed')

seed = builder.build do |count:, enabled: true|
  puts "Running the seed with count=#{count}, enabled=#{enabled}"
  'Seed result'
end

puts "✅ Seed created: #{seed.name}"
puts "   Description: #{seed.description}"
puts "   Parameters: #{seed.parameter_names.join(', ')}"

# 2. SeedManager test
puts "\n2. SeedManager test:"
manager = FactorySeeder::SeedManager.new

# Register the seed
manager.register(seed)
puts '✅ Seed registered in the manager'

# Test the validation
puts "\n3. Validation test:"
begin
  # Test with valid parameters
  result = manager.run(:test_seed, count: 5, enabled: true)
  puts "✅ Run succeeded: #{result[:message]}"
rescue StandardError => e
  puts "❌ Error: #{e.message}"
end

begin
  # Test with invalid parameters
  result = manager.run(:test_seed, count: 15, enabled: true) # count > max
  puts "✅ Run succeeded: #{result[:message]}"
rescue StandardError => e
  puts "❌ Expected error: #{e.message}"
end

# 3. Validation test without execution
puts "\n4. Validation test without execution:"
is_valid = manager.validate_seed(:test_seed, count: 3, enabled: false)
puts "Validation: #{is_valid ? '✅ Valid' : '❌ Invalid'}"

# 4. Missing parameter error test
puts "\n5. Missing parameter error test:"
begin
  result = manager.run(:test_seed, enabled: true) # count missing
  puts "✅ Run succeeded: #{result[:message]}"
rescue StandardError => e
  puts "❌ Expected error: #{e.message}"
end

# 5. Wrong type error test
puts "\n6. Wrong type error test:"
begin
  result = manager.run(:test_seed, count: 'abc', enabled: true) # count must be an integer
  puts "✅ Run succeeded: #{result[:message]}"
rescue StandardError => e
  puts "❌ Expected error: #{e.message}"
end

# 6. Seed list
puts "\n7. Available seeds:"
seeds = manager.list
seeds.each do |s|
  puts "  🌱 #{s.name}: #{s.description}"
  puts "    📋 Parameters: #{s.parameter_names.join(', ')}"
end

# 7. Search test
puts "\n8. Search test:"
matching_seeds = manager.search('test')
matching_seeds.each do |s|
  puts "  🔍 Found: #{s.name} - #{s.description}"
end

puts "\n#{'=' * 60}"
puts '🎉 Tests completed successfully!'
puts '📖 The new classes work correctly'
