# Entity Mapper
Clean Architecture entity mapping made simple.

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

## Description
A lightweight code generator for Dart that creates type-safe Entity ↔ Model mapping methods using dart_mappable-style patterns. Perfect for Clean Architecture and Domain-Driven Design.

## Features

- 🎯 **Focused Scope**: Only Entity ↔ Model mapping (not full class generation)
- 🔄 **"dart_mappable" Pattern**: Industry-standard approach
- 🏗️ **Clean Architecture**: Specifically designed for DDD patterns
- ⚡ **Light Weight**: No unnecessary class generation
- 🛠️ **Customizable**: Support for custom field mappings and transformations

## Installation 💻

**❗ In order to start using Entity Mapper you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Add to your `pubspec.yaml`:

```yaml
dependencies:
  entity_mapper: ^0.1.0

dev_dependencies:
  build_runner: ^2.6.0
```

Install it:

```sh
flutter pub get
```

## Usage 🚀

### 1. Define Your Entity and Model

```dart
// Domain Entity (Pure)
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
}

// Data Model (w/ Data manipulation methods)
part 'user_model.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
}
```

### 2. Run Code Generation

```sh
flutter packages pub run build_runner build
```

### 3. Use Generated Methods/Mappers

```dart
// Create entity
final user = User(
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  createdAt: DateTime.now(),
);

// Convert entity to model
final userModel = UserEntityMapper.toModel(user);

// Convert model to entity
final userEntity1 = userModel.toEntity();
final userEntity2 = UserEntityMapper.toEntity(userModel);
```

## Advanced Usage

### Custom Field Mappings

```dart
@MapToEntity(
  User,
  fieldMappings: {
    'fullName': 'name',  // Map 'fullName' field to 'name' in entity
  },
)
class UserModel with UserEntityMappable {
  final String id;
  final String fullName;  // Different field name
  final String email;
  
  // ...
}
```

### Ignoring Fields

```dart
class UserModel with UserEntityMappable {
  final String id;
  final String name;
  
  @EntityField(ignore: true)
  final String internalField;  // This field will be ignored during mapping
  
  // ...
}
```

### Custom Field Names

```dart
class UserModel with UserEntityMappable {
  final String id;
  
  @EntityField(name: 'user_name')
  final String name;  // Maps to 'user_name' field in entity
  
  // ...
}
```

### Nested Models

```dart
// Domain Entities (Pure)
class Car {
  const Car({
    required this.brand,
    required this.model,
    required this.engine,
  });
  
  final String brand;
  final String model;
  final Engine engine;
}

class Engine {
  const Engine({
    required this.type,
    required this.horsepower,
  });
  
  final String type;
  final int horsepower;
}

// Data Models (w/ Data manipulation methods)
@MapToEntity(Car)
class CarModel with CarEntityMappable {
  const CarModel({
    required this.brand,
    required this.model,
    required this.engine,
  });
  
  final String brand;
  final String model;
  final EngineModel engine;
}

@MapToEntity(Engine)
class EngineModel with EngineEntityMappable {
  const EngineModel({
    required this.type,
    required this.horsepower,
  });
  
  final String type;
  final int horsepower;
}
```

## API Reference

### Annotations

#### `@MapToEntity(Type entityType)`
Marks a class for automatic entity mapping generation.

**Parameters:**
- `entityType`: The entity type to map to/from
- `generateToModel`: Whether to generate the `toModel` method (default: `true`)
- `generateToEntity`: Whether to generate the `toEntity` method (default: `true`)
- `fieldMappings`: Custom field mappings for complex transformations

#### `@EntityField({String? name, bool ignore, String? customTransform})`
Provides additional metadata for entity field mapping.

**Parameters:**
- `name`: Custom name for the field in the entity
- `ignore`: Whether to ignore this field during mapping (default: `false`)
- `customTransform`: Custom transformation expression

## Examples

Check out the [example](example/) directory for more detailed examples.

---

## Continuous Integration 🤖

Entity Mapper comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

For first time users, install the [very_good_cli][very_good_cli_link]:

```sh
dart pub global activate very_good_cli
```

To run all unit tests:

```sh
very_good test --coverage
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows

## Keywords

#clean-architecture #entity-mapping #code-generation #domain-driven-design #dart-mappable #build-runner #source-gen