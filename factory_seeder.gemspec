# frozen_string_literal: true

require_relative 'lib/factory_seeder/version'

Gem::Specification.new do |spec|
  spec.name = 'factory_seeder'
  spec.version = FactorySeeder::VERSION
  spec.authors = ['FactorySeeder Team']
  spec.email = ['team@factoryseeder.com']

  spec.summary = 'A gem to simplify database seeding using FactoryBot factories'
  spec.description = 'FactorySeeder provides an intuitive interface to generate database seeds using your existing FactoryBot factories, traits, and associations.'
  spec.homepage = 'https://github.com/factoryseeder/factory_seeder'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob('{bin,lib,templates}/**/*') + %w[README.md LICENSE.txt]
  spec.bindir = 'bin'
  spec.executables = ['factory_seeder']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 6.0'
  spec.add_dependency 'factory_bot', '~> 6.0'
  spec.add_dependency 'faker', '~> 3.0'
  spec.add_dependency 'sinatra', '~> 2.0'
  spec.add_dependency 'sinatra-contrib', '~> 2.0'
  spec.add_dependency 'thor', '~> 1.0'
  spec.add_dependency 'webrick', '~> 1.7'

  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
end
