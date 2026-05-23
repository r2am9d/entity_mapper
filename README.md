<h1 align="center">entity_mapper</h1>

[![Pub Version][pub_version_badge]][pub_version_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

[Quick Start](#quick-start) • [Documentation](#overview) • [Example](example/) • [API Docs][api_docs_link] • [GitHub][github_link]

**Clean Architecture entity mapping made simple.**

A lightweight code generator that creates type-safe Entity ↔ Model mapping methods. Perfect for Clean Architecture and Domain-Driven Design applications where your `lib/domain/` layer must stay free of infrastructure dependencies.

---

## Features

- 🎯 **Clean Architecture friendly** — domain entities stay pure Dart with zero codegen dependencies; only data-layer models carry the `@MapToEntity` annotation.
- 🪶 **Pure Dart package** — no Flutter dependency. Works in Flutter apps, Dart server-side projects, and CLI tools alike.
- ⚡ **Zero runtime overhead** — all mapping code is generated at build time.
- 🛡️ **Fully type-safe** — generated code maintains complete type safety; missing or mismatched fields surface at codegen time, not runtime.
- 🔄 **Primitives, nested models, and lists** — `String`, `int`, `DateTime`, `List<T>`, `FooModel`, and `List<FooModel>` are all mapped correctly.
- 🌓 **Nullability handled end-to-end** — `String?`, `FooModel?`, and `List<FooModel>?` round-trip without null-check accidents.
- 🪄 **Lenient required-nullable** — a `required` model field whose entity counterpart is missing is filled with `null` when its type is nullable; non-nullable cases fail at codegen with a clear message.
- 🧩 **Just specify the entity type** — one annotation, one mixin, done.

---

## Quick Start

**Requirements:** Dart SDK ≥ 3.11.0. No Flutter SDK needed (Flutter projects work too).

Add dependencies:

```yaml
dependencies:
  entity_mapper: ^latest
dev_dependencies:
  build_runner: ^latest
```

Or via CLI:

```sh
dart pub add entity_mapper
dart pub add build_runner --dev
```

(`flutter pub add` works identically in Flutter projects.)

Define your pure-Dart domain entities and your data-layer models:

```dart
// lib/domain/user.dart — pure Dart, no codegen, no annotations
class User {
  const User({required this.id, required this.name, required this.age});

  final String id;
  final String name;
  final int age;
}
```

```dart
// lib/data/user_model.dart — annotated with @MapToEntity
import 'package:entity_mapper/entity_mapper.dart';

import '../domain/user.dart';

part 'user_model.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({required this.id, required this.name, required this.age});

  final String id;
  final String name;
  final int age;
}
```

Generate the mapping code:

```sh
dart run build_runner build
```

Use the generated API:

```dart
const user = User(id: 'u1', name: 'Alice', age: 30);

// Entity → Model
final model = UserEntityMapper.toModel(user);

// Model → Entity (via mixin)
final back = model.toEntity();

// Or via the static API
final back2 = UserEntityMapper.toEntity(model);
```

---

## Overview

### The annotation

`@MapToEntity(EntityType)` tells the generator which domain entity this model maps to. Apply it to your data-layer model and mix in `<Model>EntityMappable`:

```dart
@MapToEntity(User)
class UserModel with UserEntityMappable {
  // ...
}
```

The mixin name is derived by stripping the `Model` suffix from your class name and adding `EntityMappable`. `UserModel` → `UserEntityMappable`. `AddressModel` → `AddressEntityMappable`.

### Generated API

For every annotated `XModel` targeting entity `X`, the generator produces:

**Static mapper class — `XEntityMapper`:**

| Member                                 | What it does                                                                           |
| -------------------------------------- | -------------------------------------------------------------------------------------- |
| `XEntityMapper.toModel(X entity)`      | Convert an entity instance to its model.                                               |
| `XEntityMapper.toEntity(XModel model)` | Convert a model instance to its entity.                                                |
| `XEntityMapper.ensureInitialized()`    | Returns a singleton accessor. Useful when wiring DI or asserting the mapper is loaded. |

**Mixin — `XEntityMappable`:**

| Member             | What it does                                                   |
| ------------------ | -------------------------------------------------------------- |
| `model.toEntity()` | Instance-side convenience for `XEntityMapper.toEntity(model)`. |

---

## Field mapping rules

The generator handles every common field shape automatically. Below is the full table of what it emits.

| Field shape on the model                              | What the generator emits (entity → model direction)                  |
| ----------------------------------------------------- | -------------------------------------------------------------------- |
| Primitive (`String`, `int`, `bool`, `DateTime`, etc.) | `entity.field`                                                       |
| `XModel` (non-list nested model)                      | `XEntityMapper.toModel(entity.field)`                                |
| `XModel?`                                             | `entity.field == null ? null : XEntityMapper.toModel(entity.field!)` |
| `List<XModel>`                                        | `entity.field.map(XEntityMapper.toModel).toList()`                   |
| `List<XModel>?`                                       | `entity.field?.map(XEntityMapper.toModel).toList()`                  |
| `List<String>` (primitive list)                       | `entity.field` (passthrough, no mapping)                             |

The reverse direction (`toEntity`) emits the mirror of each rule.

### Naming convention

The generator detects "this is a nested model field" by checking that the field's type name ends with `Model`. So `EngineModel` triggers nested mapping; `Engine` does not. Stick to the `<EntityName>Model` convention and everything works automatically.

---

## Advanced usage

### Non-list nested model

```dart
@MapToEntity(Car)
class CarModel with CarEntityMappable {
  const CarModel({required this.brand, required this.engine});

  final String brand;
  final EngineModel engine; // generator emits EngineEntityMapper.toModel/toEntity
}

@MapToEntity(Engine)
class EngineModel with EngineEntityMappable {
  const EngineModel({required this.type, required this.horsepower});

  final String type;
  final int horsepower;
}
```

### List of nested models

```dart
@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({required this.id, required this.addresses});

  final String id;
  final List<AddressModel> addresses;
}
```

### Nullability — every variant supported

```dart
@MapToEntity(Profile)
class ProfileModel with ProfileEntityMappable {
  const ProfileModel({
    this.id,
    this.address,
    this.tags,
  });

  final String? id;                 // null preserved both ways
  final AddressModel? address;      // null-or-nested, generator emits a null guard
  final List<AddressModel>? tags;   // null-or-list, generator emits `?.map(...)`
}
```

### Required-nullable field with no entity counterpart

If your model declares `required` parameters and some of them have no field on the entity, the generator behaves as follows:

- **Nullable field type** → the generator inserts `null` so the `required` keyword is satisfied.
- **Non-nullable field type** → codegen fails with a clear `InvalidGenerationSourceError` naming the offending field — fix at the source rather than letting broken code ship.

```dart
// Entity has only id + name.
class PartialUser {
  const PartialUser({required this.id, required this.name});

  final String id;
  final String name;
}

// Model declares an extra required-nullable field.
@MapToEntity(PartialUser)
class PartialUserExtraModel with PartialUserExtraEntityMappable {
  const PartialUserExtraModel({
    required this.id,
    required this.name,
    required this.extra, // generator passes `null` here
  });

  final String id;
  final String name;
  final String? extra;
}
```

### Strictness on the other direction

If the **entity** has a `required` field with **no counterpart on the model**, codegen fails immediately. Models must be capable of capturing all of an entity's required state.

---

## Use with Clean Architecture

Recommended directory layout:

```
lib/
├── domain/
│   └── entities/             # Pure Dart. No annotations. No codegen.
│       └── user.dart
├── data/
│   ├── models/               # Annotated with @MapToEntity.
│   │   └── user_model.dart
│   └── repositories/
│       └── user_repository_impl.dart
└── ...
```

Why this works well:

- `lib/domain/` has zero dependency on `entity_mapper`. The domain layer can be unit-tested with no codegen step and reused in pure-Dart contexts.
- `lib/data/` knows about both the entity (imports from `domain/`) and the generated mapper. Repository implementations call `UserEntityMapper.toModel(...)` / `model.toEntity()` at the layer boundary.
- Adding `dart_mappable` to the same model class is supported — `UserModel` can simultaneously mix in `UserEntityMappable` (for the entity bridge) and `UserModelMappable` (for `fromJson` / `toJson` / `copyWith`).

---

## API Reference

Full API documentation is available at [pub.dev documentation](https://pub.dev/documentation/entity_mapper/latest/).

### `@MapToEntity(Type entityType)`

| Parameter    | Type   | Description                                                            |
| ------------ | ------ | ---------------------------------------------------------------------- |
| `entityType` | `Type` | The entity class this model maps to. Must be a `class`, not a typedef. |

```dart
@MapToEntity(User)
class UserModel with UserEntityMappable {
  // ...
}
```

### Generated members

See the [Generated API](#generated-api) table above.

---

## Examples

The [`example/main.dart`](example/main.dart) file is a single runnable program that demonstrates every supported scenario — primitives, non-list nested models, list-of-nested, nullable variants, required-nullable with missing entity counterpart, and the mixin-vs-static API. Run it from the package root:

```sh
dart run build_runner build
dart run example/main.dart
```

---

## Compatibility

| Tool         | Minimum | Tested up to |
| ------------ | ------- | ------------ |
| Dart SDK     | 3.11.0  | 3.11.x       |
| `analyzer`   | 10.0.0  | 13.0.0       |
| `build`      | 3.0.0   | 4.x          |
| `source_gen` | 3.1.0   | 4.x          |

Older `analyzer` versions are unsupported — `entity_mapper` 0.5.0 uses the canonical (unsuffixed) Element API.

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

To run the test suite (44 tests covering every supported scenario):

```sh
dart run build_runner build
dart test
```

## License

This project is licensed under the terms of the [MIT License](LICENSE).

## Support & Contact

For issues, feature requests, or questions, please open a [GitHub Issue](https://github.com/r2am9d/entity_mapper/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes and version history.

## Keywords

#clean-architecture #entity-mapping #code-generation #domain-driven-design #ddd #build-runner #source-gen #dart

[pub_version_badge]: https://img.shields.io/pub/v/entity_mapper.svg
[pub_version_link]: https://pub.dev/packages/entity_mapper
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[github_link]: https://github.com/r2am9d/entity_mapper
[api_docs_link]: https://pub.dev/documentation/entity_mapper/latest
