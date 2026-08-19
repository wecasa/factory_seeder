#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage example for the new custom seeds management
# This file demonstrates how to use the new features

require_relative 'lib/factory_seeder'

# Configuration
FactorySeeder.configure do |config|
  config.verbose = true
end

puts '🌱 FactorySeeder Custom Seeds usage example'
puts '=' * 60

# 1. Defining a simple seed
puts "\n1. Defining a simple seed:"
FactorySeeder.define_seed(:hello_world, lambda { |builder|
  builder
    .description('A simple seed that says hello')
    .string_param(:name, required: true, description: 'Name to greet')
    .integer_param(:count, required: false, default: 1, min: 1, max: 5, description: 'Number of greetings')
}) do |name:, count: 1|
  count.times do |i|
    puts "👋 Hello #{name}! (#{i + 1}/#{count})"
  end
  puts "✅ Seed 'hello_world' ran successfully"
end

# 2. Defining a more complex seed
puts "\n2. Defining a complex seed:"
FactorySeeder.define_seed(:create_sample_data, lambda { |builder|
  builder
    .description('Create sample data with validation')
    .integer_param(:user_count, required: true, min: 1, max: 10, description: 'Number of users')
    .boolean_param(:create_posts, required: false, default: true, description: 'Create posts')
    .symbol_param(:user_type, required: false, default: :regular, allowed_values: %i[regular premium
                                                                                     admin], description: 'User type')
    .array_param(:tags, required: false, default: %w[ruby rails], description: 'Tags to apply')
}) do |user_count:, create_posts: true, user_type: :regular, tags: %w[ruby rails]|
  puts "📊 Creating #{user_count} user(s) of type '#{user_type}'"
  puts "📝 Creating posts: #{create_posts ? 'Yes' : 'No'}"
  puts "🏷️  Tags: #{tags.join(', ')}"

  # Simulated data creation
  user_count.times do |i|
    puts "  👤 Created user ##{i + 1} (#{user_type})"

    puts "    📄 Created post ##{i + 1} with tags: #{tags.join(', ')}" if create_posts
  end

  puts "✅ Seed 'create_sample_data' ran successfully"
end

# 3. Validation test
puts "\n3. Parameter validation test:"
begin
  # Test with valid parameters
  result = FactorySeeder.run_custom_seed(:hello_world, name: 'Alice', count: 3)
  puts "#{result[:success] ? '✅' : '❌'} #{result[:message]}"
rescue StandardError => e
  puts "❌ Error: #{e.message}"
end

begin
  # Test with invalid parameters (count too high)
  result = FactorySeeder.run_custom_seed(:hello_world, name: 'Bob', count: 10)
  puts "#{result[:success] ? '✅' : '❌ expected failure —'} #{result[:message]}"
rescue StandardError => e
  puts "❌ Expected error: #{e.message}"
end

# 4. Validation test without execution
puts "\n4. Validation test without execution:"
is_valid = FactorySeeder.seed_manager.validate_seed(:create_sample_data,
                                                    user_count: 5,
                                                    create_posts: true,
                                                    user_type: :premium,
                                                    tags: %w[test example])
puts "Validation: #{is_valid ? '✅ Valid' : '❌ Invalid'}"

# 5. List of available seeds
puts "\n5. Available seeds:"
seeds = FactorySeeder.list_custom_seeds
seeds.each do |seed|
  puts "  🌱 #{seed.name}: #{seed.description}"
  if seed.has_parameters?
    puts "    📋 Parameters: #{seed.parameter_names.join(', ')}"
  else
    puts '    📋 No parameter'
  end
end

# 6. Seed search
puts "\n6. Searching for seeds containing 'hello':"
matching_seeds = FactorySeeder.seed_manager.search('hello')
matching_seeds.each do |seed|
  puts "  🔍 Found: #{seed.name} - #{seed.description}"
end

# 7. Missing parameter error test
puts "\n7. Missing parameter error test:"
begin
  result = FactorySeeder.run_custom_seed(:hello_world) # name missing
  puts "#{result[:success] ? '✅' : '❌ expected failure —'} #{result[:message]}"
rescue StandardError => e
  puts "❌ Expected error: #{e.message}"
end

# 8. Wrong type error test
puts "\n8. Wrong type error test:"
begin
  result = FactorySeeder.run_custom_seed(:hello_world, name: 'Charlie', count: 'abc') # count must be an integer
  puts "#{result[:success] ? '✅' : '❌ expected failure —'} #{result[:message]}"
rescue StandardError => e
  puts "❌ Expected error: #{e.message}"
end

puts "\n#{'=' * 60}"
puts '🎉 Demonstration completed!'
puts '📖 See README.md for more information'
