# entity_mapper

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

[Quick Start](#quick-start) • [Documentation](#overview) • [Example](example/) • [GitHub](https://github.com/r2am9d/entity_mapper)

**Clean Architecture entity mapping made simple.**

A lightweight code generator that creates type-safe Entity ↔ Model mapping methods using dart_mappable-style patterns. Perfect for Clean Architecture and Domain-Driven Design applications.

## Features

• 🎯 **Clean Architecture ready**: Perfect separation between domain and data layers  
• 🔄 **dart_mappable Pattern**: Industry-standard approach and familiar API  
• ⚡ **Zero runtime overhead**: All mapping code generated at build time  
• 🛠️ **Lightweight & focused**: Only Entity ↔ Model mapping (no unnecessary bloat)  
• 🔒 **Fully type-safe**: Generated code maintains complete type safety  
• 🎛️ **Highly customizable**: Custom field mappings, transformations, and more

---

## Quick Start

**Requirements:** Dart SDK ≥ 3.8.0, Flutter ≥ 3.32.0

Add dependencies:

```sh
flutter pub add entity_mapper
flutter pub add build_runner --dev
```

Annotate your model classes:

```dart
// domain/entities/user.dart
class User {
  const User({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;
}

// data/models/user_model.dart
import 'package:entity_mapper/entity_mapper.dart';

part 'user_model.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;
}
```

Generate code and use:

```sh
dart run build_runner build
```

```dart
// Convert entity ↔ model
final user = User(id: '1', name: 'John', email: 'john@example.com');
final userModel = UserEntityMapper.toModel(user);
final backToEntity = userModel.toEntity();
```

---

## Overview

### Annotations

Use `@MapToEntity()` on model classes to specify the target entity and generation options:

```dart
@MapToEntity(
  User,                        // Target entity type
  generateToModel: true,       // Generate entity → model (default: true)
  generateToEntity: true,      // Generate model → entity (default: true)
  fieldMappings: {            // Custom field name mappings
    'fullName': 'name',
  },
)
class UserModel with UserEntityMappable { ... }
```

Use `@EntityField()` on individual fields for customization:

```dart
class UserModel with UserEntityMappable {
  @EntityField(name: 'user_name')                    // Custom entity field name
  final String name;
  
  @EntityField(ignore: true)                         // Skip during mapping
  final String internalId;
  
  @EntityField(customTransform: 'value.toUpperCase()') // Custom transformation
  final String code;
}
```

### Generated API

**Static Mapper Classes:**
- `{Entity}EntityMapper.toModel(entity)` - Convert entity to model
- `{Entity}EntityMapper.toEntity(model)` - Convert model to entity

**Mixin Methods:**
- `toEntity()` - Convert this model instance to entity

---

## Advanced Usage

### Custom Field Mappings
```dart
@MapToEntity(
  User,
  fieldMappings: {
    'fullName': 'name',        // fullName in model → name in entity
    'emailAddress': 'email',   // emailAddress in model → email in entity
  },
)
class UserModel with UserEntityMappable {
  final String fullName;      // Maps to 'name'
  final String emailAddress;  // Maps to 'email'
}
```

### Selective Generation
```dart
@MapToEntity(User, generateToEntity: false)  // Only entity → model
class ReadOnlyUserModel with UserEntityMappable { ... }

@MapToEntity(User, generateToModel: false)   // Only model → entity  
class WriteOnlyUserModel with UserEntityMappable { ... }
```

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

---

## API Reference

### `@MapToEntity(Type entityType, {bool generateToModel, bool generateToEntity, Map<String, String> fieldMappings})`

**Parameters:**
- `entityType` - The entity type to map to/from
- `generateToModel` - Generate entity → model method (default: true)
- `generateToEntity` - Generate model → entity method (default: true)  
- `fieldMappings` - Custom field name mappings

### `@EntityField({String? name, bool ignore, String? customTransform})`

**Parameters:**
- `name` - Custom field name in the entity
- `ignore` - Skip this field during mapping (default: false)
- `customTransform` - Custom transformation expression

---

## Examples

Check out the [example](example/) directory for complete examples including nested models, custom transformations, and real-world Clean Architecture scenarios.

---

## Contributing

Contributions welcome! Submit issues and pull requests on [GitHub](https://github.com/r2am9d/entity_mapper).

## License

[MIT License](LICENSE)

## Keywords

#clean-architecture #entity-mapping #code-generation #domain-driven-design #dart-mappable #build-runner #source-gen

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis