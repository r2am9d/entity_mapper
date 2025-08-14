# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2025-08-14

### Added
- **Nullability Support**: Models and entities now support nullable fields and lists, with robust mapping logic for nulls and empty collections.
- **Nested List Mapping**: Automatic mapping for nested lists of models/entities, including deep conversion and round-trip tests.
- **Comprehensive Example Update**: `example/main.dart` now demonstrates bi-directional mapping, nullability, and nested lists, matching real-world Clean Architecture scenarios.
- **Best Practices Documentation**: Updated `README.md` to emphasize direct imports, pure Dart entities, and avoidance of problematic index files in tests.

### Changed
- **Test Suite Refactor**: Test files now define models directly or import only pure Dart entities, avoiding central index files and problematic dependencies.
- **Mapping Logic Hardening**: Improved error handling and edge case coverage in mapping logic, including multi-error reporting for nullability mismatches.
- **Annotation Usage**: Tests now verify annotation instantiation and usage, with static checks and string output validation.
- **README.md Overhaul**: Documentation now reflects latest patterns, nullability, nested lists, and best practices for both usage and testing.

### Fixed
- **Test Runner Compatibility**: Resolved issues with test runner hangs and `dart:mirrors` import errors by isolating model imports and cleaning dependency usage.
- **Code Generation Consistency**: Ensured generated mapper code is always in sync with model/entity definitions, including nullability and nested collections.

### Why This Change
- **Reliability**: Mapping logic and tests now robustly handle nulls, lists, and edge cases, reducing risk of runtime errors.
- **Developer Experience**: Documentation and examples are clearer, easier to follow, and match best practices from leading Dart mapping libraries.
- **Test Stability**: Test suite is more maintainable and less prone to dependency or import issues.
- **Real-World Usability**: Example and API now reflect actual Clean Architecture and DDD usage patterns.

### Migration Guide
**Before:**
- Models/entities may not support nulls or nested lists.
- Tests may import models via central index files, risking runner errors.
- Documentation may not reflect latest patterns.

**After:**
- Models/entities support nulls and nested lists.
- Tests import only pure Dart entities or define models directly.
- Documentation and examples match current best practices.

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
