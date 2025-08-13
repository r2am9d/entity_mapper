# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2025-08-13

### Changed
- **BREAKING**: Simplified `@MapToEntity` annotation to only accept `entityType` parameter
- **BREAKING**: Removed `@EntityField` annotation entirely
- **BREAKING**: Removed `generateToModel`, `generateToEntity`, and `fieldMappings` configuration options
- **BREAKING**: Always generates both toModel and toEntity methods (no conditional generation)
- **BREAKING**: Only supports direct field name mapping (no custom field mappings)

### Removed
- **BREAKING**: `@EntityField` annotation and all its functionality
- **BREAKING**: Custom field mapping configuration via `fieldMappings`
- **BREAKING**: Conditional method generation flags
- **BREAKING**: Custom field transformations

### Why This Change
Simplified the package to focus on its core purpose:
- **Reduced complexity**: Removed unused and over-engineered features
- **Better maintainability**: Cleaner codebase with fewer edge cases
- **Easier adoption**: Simpler API with just one required parameter
- **Focus on essentials**: Entity ↔ Model mapping with direct field mapping

### Migration Guide
**Before:**
```dart
@MapToEntity(
  User,
  generateToModel: true,
  generateToEntity: true,
  fieldMappings: {'name': 'fullName'},
)
class UserModel with UserEntityMappable { ... }

@EntityField(name: 'custom_name')
final String name;
```

**After:**
```dart
@MapToEntity(User)
class UserModel with UserEntityMappable { ... }

// Ensure field names match between model and entity
final String name; // Must match entity field name
```

## [0.2.0] - 2025-08-13

### Changed
- **BREAKING**: Removed `toModel()` instance method from generated mixin for cleaner API semantics
- Entity → Model conversion now only available via static `{Entity}EntityMapper.toModel(entity)` method
- Improved API clarity by removing semantically incorrect method

### Fixed
- Eliminated confusing API where model instances could convert entities to models
- Better separation of concerns: static methods for entity→model, instance methods for model→entity

### Why This Change
The `toModel()` instance method on the mixin was semantically incorrect and confusing:
- Calling `userModel.toModel(entity)` didn't make logical sense
- It created ambiguity in the API
- No real-world use case existed for this pattern

**Migration**: Replace `model.toModel(entity)` with `EntityMapper.toModel(entity)`

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
- **Code Generation**: Automatically generates mapping code at build time
- **Type Safety**: Generated code is fully type-safe
- **Zero Runtime Overhead**: All mapping logic is generated at compile time
- **Flexible Configuration**: Customizable field mappings and transformations
- **Clean API**: Simple annotations with intuitive usage
- **Comprehensive Testing**: Extensive test coverage for reliability

### Documentation
- Complete README with installation and usage instructions
- API documentation for all annotations and features
- Real-world examples and best practices
