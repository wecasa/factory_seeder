# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of FactorySeeder gem
- Automatic factory detection and scanning
- CLI interface with interactive mode
- Web interface with beautiful UI
- Support for FactoryBot traits and associations
- Preview functionality for data validation
- Configuration system for different environments
- Ruby API for programmatic seeding
- Template system for common seeding patterns

### Features
- **FactoryScanner**: Automatically detects and analyzes FactoryBot factories
- **SeedGenerator**: Creates database records using factories and traits
- **CLI Interface**: Command-line tool with interactive prompts
- **Web Interface**: Modern web UI for visual seeding
- **Configuration**: Flexible configuration system
- **Preview Mode**: See data before creating records
- **Association Support**: Handle complex model relationships
- **Environment Support**: Different settings per environment

### Changed
- CLI `list` now reports each factory's class name, traits, associations, and attribute hints so the CLI equals the web experience.
- CLI `generate`/`preview` default to `config.default_count`/`config.default_strategy` when options are omitted and accept JSON payloads for `--attributes`.

### Technical Details
- Built on top of FactoryBot 6.x
- Uses Thor for CLI interface
- Sinatra for web interface
- ActiveSupport for Rails integration
- Faker for realistic test data generation

## [0.1.0] - 2024-08-19

### Added
- Initial release
- Core functionality implemented
- Basic CLI and web interfaces
- Factory scanning and analysis
- Seed generation with traits and associations
- Configuration system
- Documentation and examples
