/// Clean Architecture entity mapping made simple with code generation
///
/// This package provides annotations and code generation to automatically
/// create mapping methods between your domain entities and data models.
///
/// Example usage:
/// ```dart
/// import 'package:entity_mapper/entity_mapper.dart';
///
/// @MapToEntity(User)
/// class UserModel with UserEntityMappable {
///   const UserModel({
///     required this.id,
///     required this.name,
///   });
///
///   final String id;
///   final String name;
/// }
/// ```
library;

export 'src/annotations/entity_field.dart';
export 'src/annotations/map_to_entity.dart';
