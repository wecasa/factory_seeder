# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Created Records Reporting
- **RecordTracker**: Global FactoryBot `after(:create)` hook collecting every persisted
  record during a run, associations included. No-op outside of a tracked run
- **Result payload**: `created_records` and `records_summary` returned by
  `SeedGenerator#generate` and `SeedManager#run`
- **Execution logs**: one line per created record (`Model #id (label)`) plus a summary
  line, capped by the new `config.log_records_limit` (default 50)
- **Rails engine UI**: `Created Records` panel on the factory and custom seed pages
- **CLI**: created records summary printed after `generate` and `seeds`
- **CLI**: `factory_seeder seeds NAME --params key:value` now runs custom seeds
  declared in `db/factory_seeds/`, and `seeds --list` lists them
- **Partial results**: records created before a seed raises are still reported
- **Typed parameter shorthands**: `string_param`, `integer_param`, `boolean_param`,
  `symbol_param` and `array_param` on `SeedBuilder`, which the README and the
  example scripts already documented but which did not exist

#### Core Features
- **Automatic Factory Detection**: Scans and analyzes FactoryBot factories automatically
- **CLI Interface**: Command-line tool with interactive mode using Thor
- **Web Interface**: Rails Engine UI for visual seeding
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
- **Custom Seeds Dashboard**: Browse and execute custom seeds with parameter forms
- **Execution Logs**: Capture and display execution logs in console panel

### Removed
- **Standalone Sinatra interface**: `factory_seeder web`, `FactorySeeder::WebInterface`,
  the `views/` templates, the `GET /api/factories` and `GET /api/factory/:name/preview`
  JSON endpoints, and the sinatra, sinatra-contrib and webrick dependencies. The
  templates were never packaged in the gem, so the standalone app could not run from
  an installed gem. The Rails engine is the only supported UI
- **Run-all seeds**: `factory_seeder seeds --all`, `SeedManager#run_all` and
  `SeedGenerator#run_all_seeds`. On the custom-seed path it reported success while
  running nothing, because it iterated a registry custom seeds never populate
- **`factory_seeder seeds --dry_run`**: it only printed a banner, then created the
  records anyway
- **Engine seed routes**: `POST /seeds` (`run_all_seeds`) and `POST /seeds/:name`
  (`run_seed`), along with their `DashboardController` actions. Both were stubs that
  only set a "Seed system coming soon!" flash; the `run_all_seeds_path` and
  `run_seed_path` helpers are gone
- **Legacy seeds path**: `FactorySeeder::Seeder`, `FactorySeeder.generate`, `.seeder`,
  `.list_seeds`, `.run`, `SeedGenerator#define_seed`/`#run_seed`/`#list_seeds`/`#has_seed?`
  and the `db/seeds_factory_seeder.rb` file. It never worked: `Seeder` had no
  `define_seed`, and the CLI looked seeds up in a `SeedGenerator` registry nothing
  populated. `db/factory_seeds/*.rb` is now the only way to declare a seed
- **Unreachable view**: `app/views/factory_seeder/seeds/show.html.erb`, which had no
  controller and no route

### Changed
- **BREAKING -- FactoryBot floor raised to 6.0** (from 5.0): `RecordTracker` needs
  `FactoryBot::Internal.callbacks`, introduced in 6.0, to tell whether its global
  callback survived a `FactoryBot.reload`
- **`factory_seeder init`**: creates `db/factory_seeds/example.rb` from the seed
  template instead of a `db/seeds_factory_seeder.rb` that used a non-existent API
- **`templates/seed_template.rb`**: rewritten against the API that actually exists;
  it documented `Seeder#create` and `#create_with_associations`, neither of which
  was ever defined
- **Dashboard**: the seed count and tags now come from the real custom seed registry
  instead of the always-empty legacy one
- **Custom seed parameter coercion**: moved to `Seed#coerce_parameters`, shared by the
  CLI and the web controller, which had drifted apart on booleans and blank values
- **CLI `list` command**: Now reports class name, traits, associations, and attribute hints
- **CLI `generate` and `preview`**: Default to `config.default_count` and `config.default_strategy` when options are omitted
- **Attribute Support**: Accept JSON payloads for `--attributes` in CLI
- **Factory Loading**: Improved error handling with retry mechanism for failed factories
- **Model Class Resolution**: Safer approach using inferred class names when models aren't loaded
- **Custom Seed Reloading**: Rails engine reloads `db/factory_seeds/*.rb` automatically on each request

### Technical Details

#### Architecture
- **FactoryScanner**: Detects and analyzes FactoryBot factories with robust error handling
- **SeedGenerator**: Creates database records using factories, traits, and custom attributes
- **SeedManager**: Manages custom seed registry with validation
- **Seed**: Represents a seed definition with parameters and metadata
- **SeedBuilder**: DSL for building seed definitions
- **CLI**: Thor-based command-line interface
- **Engine**: Rails::Engine for Rails integration
- **Configuration**: Centralized configuration management
- **CustomSeedLoader**: Auto-loads custom seeds from `db/factory_seeds/`
- **RecordTracker**: Collects the records FactoryBot persists during a run

#### Dependencies
- Built on FactoryBot 6.x
- Thor for CLI interface
- ActiveSupport for Rails integration
- Faker for realistic test data
- Zeitwerk for autoloading

### Fixed
- **Tracking surviving a FactoryBot reload**: `RecordTracker` checks the callback is
  still registered instead of trusting a boolean. `FactoryBot.reload`, which
  `factory_bot_rails` runs on every `to_prepare`, discards global callbacks, so
  tracking silently stopped after the first file edit in development
- **Duplicate callback registration**: guarded by a mutex, so concurrent first runs
  cannot register the hook twice and double-count every record
- **Labels never breaking a run**: `RecordTracker.track` no longer lets an exception
  escape the `after(:create)` callback, which turned successful inserts into reported
  failures. Labels are restricted to scalars and skip associations, avoiding a query
  per created record
- **Fiber-created records**: tracking storage is thread-local rather than fiber-local
- **Unpersisted records**: `build` strategy and `skip_create` factories no longer report
  records that were never saved
- **`CustomSeedLoader.reload!` no longer clears the whole registry**: it drops only the
  seeds it loaded itself, so seeds registered from an initializer or a console survive.
  The Rails engine reloads on every `to_prepare`, so those seeds used to disappear on
  the first request
- **`filter_association_attributes`**: `FactoryBot.factories.find` was called with a
  block, but `Registry#find` takes a name -- it raised on its first line every time and
  silently fell through to a much cruder fallback filter
- **`build` strategy on non-persistable models**: records whose class has no `save!` are
  counted again instead of being silently skipped
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
