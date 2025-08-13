# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-08-13

### Added
- Initial release of Entity Mapper package
- `@MapToEntity` annotation for marking classes for entity mapping generation
- `@EntityField` annotation for custom field mapping configuration
- Automatic code generation for entity-to-model and model-to-entity mapping
- Static mapper classes with `toModel` and `toEntity` methods
- Mixin support for instance methods on models
- Support for custom field mappings and transformations
- Support for ignoring specific fields during mapping
- Comprehensive test suite with integration and functional tests
- Complete documentation with usage examples
- Clean Architecture pattern support
- Flutter and Dart compatibility

### Features
- **Focused Scope**: Only Entity ↔ Model mapping (not full class generation)
- **"dart_mappable" Pattern**: Industry-standard approach
- **Clean Architecture**: Specifically designed for DDD patterns
- **Light Weight**: No unnecessary class generation
- **Customizable**: Support for custom field mappings and transformations

### Documentation
- Complete README with installation and usage instructions
- API documentation for all annotations and features
- Real-world examples and best practices
- Migration guides and troubleshooting tips
