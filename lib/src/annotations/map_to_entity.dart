// ignore_for_file: public_member_api_docs, document_ignores, lines_longer_than_80_chars

/// Annotation to mark a data model class that should have entity mapping methods generated
class MapToEntity {
  const MapToEntity(this.entityType);

  /// The entity type to map to/from
  final Type entityType;
}
