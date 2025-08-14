/// Annotation to mark a data model class for entity mapping code generation.
///
/// Usage:
/// ```dart
/// @MapToEntity(User)
/// class UserModel {
///   // ...
/// }
/// ```
///
/// [entityType] must be a valid Dart type representing the target entity.
///
class MapToEntity {
  /// Creates a [MapToEntity] annotation.
  const MapToEntity(this.entityType);

  /// The entity type to map to/from.
  final Type entityType;
}
