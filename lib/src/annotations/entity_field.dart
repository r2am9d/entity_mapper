// ignore_for_file: public_member_api_docs, document_ignores, lines_longer_than_80_chars

/// Annotation to provide additional metadata for entity field mapping
class EntityField {
  const EntityField({
    this.name,
    this.ignore = false,
    this.customTransform,
  });

  /// Custom name for the field in the entity
  final String? name;

  /// Whether to ignore this field during mapping
  final bool ignore;

  /// Custom transformation expression
  final String? customTransform;
}
