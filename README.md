<h1 align="center">entity_mapper</h1>

[![Pub Version][pub_version_badge]][pub_version_link]
[![Coverage][coverage_badge]][coverage_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason][mason_badge]][mason_link]
[![License: MIT][license_badge]][license_link]

[Quick Start](#quick-start) • [Documentation](#overview) • [Example](example/) • [API Docs][api_docs_link] • [GitHub][github_link]


**Clean Architecture entity mapping made simple.**

A lightweight code generator that creates type-safe Entity ↔ Model mapping methods using dart_mappable-style patterns. Perfect for Clean Architecture and Domain-Driven Design applications.

---

## Features


• 🎯 **Clean Architecture ready**: Perfect separation between domain and data layers  
• 🔄 **dart_mappable Pattern**: Familiar API and generated code  
• ⚡ **Zero runtime overhead**: All mapping code generated at build time  
•  **Fully type-safe**: Generated code maintains complete type safety   
• 🧪 **Nullability & Collections**: Handles nullable fields and nested lists automatically  
• 🧩 **Simple & focused**: Just specify the entity type - that's it! 

---

## Quick Start

**Requirements:** Dart SDK ≥ 3.8.0, Flutter ≥ 3.32.0

Add dependencies:

```yaml
dependencies:
  entity_mapper: ^latest
dev_dependencies:
  build_runner: ^latest
```

Or use:

```sh
flutter pub add entity_mapper
flutter pub add build_runner --dev
```

Annotate your model classes:


```dart
// Domain Entities
class User {
  const User({
    required this.id,
    this.name,
    this.age,
    required this.addresses,
  });

  final String id;
  final String? name;
  final int? age;
  final List<Address> addresses;
}

class Address {
  const Address({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;
}

// Data Models
import 'package:entity_mapper/entity_mapper.dart';

part 'user_model.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({
    required this.id,
    this.name,
    this.age,
    required this.addresses,
  });

  final String id;
  final String? name;
  final int? age;
  final List<AddressModel> addresses;
}

@MapToEntity(Address)
class AddressModel with AddressEntityMappable {
  const AddressModel({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;
}
```

Generate code and use:

```sh
dart run build_runner build
```


```dart
// Convert model ↔ entity
const addressModel = AddressModel(street: 'Main St', city: 'Metropolis');
const userModel = UserModel(
  id: 'u1',
  name: 'Alice',
  age: 30,
  addresses: [addressModel],
);

// Model to Entity
final userEntity = userModel.toEntity();

// Entity to Model
final userModel2 = UserEntityMapper.toModel(userEntity);

// Nullability example
const userModelNull = UserModel(id: 'u2', addresses: []);
final userEntityNull = userModelNull.toEntity();
print('Null fields: name={userEntityNull.name}, age={userEntityNull.age}');
```

---

## Overview

### Annotations

Use `@MapToEntity()` on model classes to specify the target entity:

```dart
@MapToEntity(User) // Target entity type
class UserModel with UserEntityMappable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });
  final String id;
  final String name;
  final String email;
}
```

### Generated API

**Static Mapper Classes:**
- `{Model}EntityMapper.toModel(entity)` - Convert entity to model
- `{Model}EntityMapper.toEntity(model)` - Convert model to entity

**Mixin Methods:**
- `toEntity()` - Convert this model instance to entity

---

## Advanced Usage

### Nested Models
```dart
@MapToEntity(Car)
class CarModel with CarEntityMappable {
  final String brand;
  final EngineModel engine;  // Automatically handles nested mapping
}

@MapToEntity(Engine)
class EngineModel with EngineEntityMappable {
  final String type;
  final int horsepower;
}
```


### Lists
```dart
@MapToEntity(User)
class UserModel with UserEntityMappable {
  final String id;
  final List<AddressModel> addresses; // Nested model lists supported
  // ...
}
```

---

## API Reference

Full API documentation is available at [pub.dev documentation](https://pub.dev/documentation/entity_mapper/latest/).

### `@MapToEntity(Type entityType)`

**Parameters:**
- `entityType` - The entity type to map to/from

**Example:**
```dart
@MapToEntity(User)
class UserModel with UserEntityMappable {
  // Model implementation
}
```

---

## Examples

Check out the [example](example/) directory for complete examples including nested models and real-world Clean Architecture scenarios.

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

To run tests:

```sh
flutter test
```

## License

This project is licensed under the terms of the [MIT License](LICENSE).

## Support & Contact

For issues, feature requests, or questions, please use [GitHub Issues](https://github.com/r2am9d/entity_mapper/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes and version history.

## Keywords

#clean-architecture #entity-mapping #code-generation #domain-driven-design #dart-mappable #build-runner #source-gen

[pub_version_badge]: https://img.shields.io/pub/v/entity_mapper.svg
[pub_version_link]: https://pub.dev/packages/entity_mapper
[coverage_badge]: https://img.shields.io/badge/coverage-xx%25-green.svg
[coverage_link]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[mason_badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge
[mason_link]: https://github.com/felangel/mason
[github_link]: https://github.com/r2am9d/entity_mapper
[api_docs_link]: https://pub.dev/documentation/entity_mapper/latest