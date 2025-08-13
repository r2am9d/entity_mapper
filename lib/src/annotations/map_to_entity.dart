// ignore_for_file: public_member_api_docs, document_ignores, lines_longer_than_80_chars

/// Annotation to mark a data model class that should have entity mapping methods generated
class MapToEntity {
  const MapToEntity(
    this.entityType, {
    this.generateToModel = true,
    this.generateToEntity = true,
    this.fieldMappings = const {},
  });

  /// The entity type to map to/from
  final Type entityType;

  /// Whether to generate the toModel factory constructor
  final bool generateToModel;

  /// Whether to generate the toEntity method
  final bool generateToEntity;

  /// Custom field mappings for complex transformations
  /// Key: model field name, Value: entity field name or transformation
  final Map<String, String> fieldMappings;
}
