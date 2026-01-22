# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Core Features
- **Automatic Factory Detection**: Scans and analyzes FactoryBot factories automatically
- **CLI Interface**: Command-line tool with interactive mode using Thor
- **Web Interface**: Modern Sinatra-based UI for visual seeding
- **Rails Engine Integration**: Seamless Rails integration with automatic mounting
- **Ruby API**: Programmatic interface for seeding in Ruby code
- **Preview Mode**: See data before creating records
- **Configuration System**: Flexible environment-specific configuration
- **Custom Seeds System**: Define reusable seeds with parameter validation and metadata

#### Custom Seeds Features
- **SeedBuilder DSL**: Fluent interface for defining seeds with parameter validation
- **Parameter Types**: Support for integer, boolean, symbol, string, and array parameters
- **Parameter Validation**: Type checking, min/max values, allowed values, and required fields
- **Metadata Support**: Descriptions and documentation for seeds and parameters
- **Web UI for Custom Seeds**: Dynamic forms based on parameter definitions
- **Auto-reload**: Custom seeds under `db/factory_seeds/*.rb` are automatically reloaded

#### Rails Integration Improvements
- **Automatic Model Loading**: Models loaded via `config.after_initialize` hook
- **Development Reloading**: Models reloaded when files change via `config.to_prepare`
- **Conditional Eager Loading**: Only forces eager loading when necessary
- **Error Handling**: Graceful handling of uninitialized constants and missing dependencies
- **Rails Engine**: Proper Rails Engine with isolated namespace

#### CLI Enhancements
- **Detailed Factory Listing**: Shows class name, traits, associations, and key attributes
- **Default Configuration Values**: Inherits `default_count` and `default_strategy` from config
- **JSON Attribute Support**: Accept JSON payloads via `--attributes` flag
- **Verbose Mode**: Detailed error messages and loading information
- **Interactive Mode**: User-friendly prompts for factory and trait selection

#### Web Interface Features
- **Factory Metadata Display**: Shows class, traits, associations, and attributes
- **Custom Attribute Inputs**: Dynamic input fields for each factory attribute
- **Trait Selection**: Checkbox-based trait selection
- **Real-time Preview**: Preview data before generation
- **Custom Seeds Dashboard**: Browse and execute custom seeds with parameter forms
- **Auto-reload**: Standalone web calls `FactorySeeder.reload!` before each request
- **Execution Logs**: Capture and display execution logs in console panel

### Changed
- **CLI `list` command**: Now reports class name, traits, associations, and attribute hints
- **CLI `generate` and `preview`**: Default to `config.default_count` and `config.default_strategy` when options are omitted
- **Attribute Support**: Accept JSON payloads for `--attributes` in CLI
- **Factory Loading**: Improved error handling with retry mechanism for failed factories
- **Model Class Resolution**: Safer approach using inferred class names when models aren't loaded
- **Custom Seed Reloading**: Rails engine reloads `db/factory_seeds/*.rb` automatically on each request
- **Web Interface Reloading**: Standalone web interface reloads configuration and seeds on each request

### Technical Details

#### Architecture
- **FactoryScanner**: Detects and analyzes FactoryBot factories with robust error handling
- **SeedGenerator**: Creates database records using factories, traits, and custom attributes
- **SeedManager**: Manages custom seed registry with validation
- **Seed**: Represents a seed definition with parameters and metadata
- **SeedBuilder**: DSL for building seed definitions
- **CLI**: Thor-based command-line interface
- **WebInterface**: Sinatra application with JSON API
- **Engine**: Rails::Engine for Rails integration
- **Configuration**: Centralized configuration management
- **CustomSeedLoader**: Auto-loads custom seeds from `db/factory_seeds/`

#### Dependencies
- Built on FactoryBot 6.x
- Thor for CLI interface
- Sinatra for web interface
- ActiveSupport for Rails integration
- Faker for realistic test data
- Zeitwerk for autoloading
- WebRick for standalone web server

### Fixed
- **NameError handling**: Gracefully handle uninitialized constant errors during factory loading
- **Model loading race conditions**: Ensure Rails models are loaded before factory analysis
- **Trait parsing**: Correct parsing of comma-separated traits in CLI and web API
- **Factory class resolution**: Safe class name inference when models aren't loaded
- **Constant inflection**: Fixed CLI constant inflection for Zeitwerk compatibility
- **Session-based logs**: Store execution logs in session instead of flash for persistence

### Security
- Input validation for all custom seed parameters
- Type checking and sanitization for user inputs
- Protection against invalid factory names

## [0.1.0] - 2024-08-19

### Added
- Initial release
- Core functionality implemented
- Basic CLI and web interfaces
- Factory scanning and analysis
- Seed generation with traits and associations
- Configuration system
- Documentation and examples

---

For detailed usage examples and migration guides, see the README.md file.
