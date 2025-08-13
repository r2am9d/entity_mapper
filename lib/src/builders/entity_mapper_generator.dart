// ignore_for_file: public_member_api_docs, document_ignores, lines_longer_than_80_chars

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder entityMapperBuilder(BuilderOptions options) => LibraryBuilder(
  EntityMapperGenerator(),
  generatedExtension: '.entity_mapper.dart',
);

class EntityMapperGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final annotatedElements = <Element2>[];

    // Find all classes with @MapToEntity annotation
    for (final element in library.allElements) {
      if (element is ClassElement2) {
        final annotation = const TypeChecker.fromUrl(
          'package:entity_mapper/src/annotations/map_to_entity.dart#MapToEntity',
        ).firstAnnotationOf(element.firstFragment);
        if (annotation != null) {
          annotatedElements.add(element);
        }
      }
    }

    if (annotatedElements.isEmpty) {
      return '';
    }

    final buffer = StringBuffer()
      ..writeln("part of '${buildStep.inputId.path.split('/').last}';")
      ..writeln();

    // Generate extensions for all annotated classes
    for (final element in annotatedElements) {
      final annotation = const TypeChecker.fromUrl(
        'package:entity_mapper/src/annotations/map_to_entity.dart#MapToEntity',
      ).firstAnnotationOf(element.firstFragment)!;
      final annotationReader = ConstantReader(annotation);

      buffer.writeln(
        _generateForElement(
          element as ClassElement2,
          annotationReader,
          buildStep,
        ),
      );
    }

    return buffer.toString();
  }

  String _generateForElement(
    ClassElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final className = element.firstFragment.name2!;
    final entityTypeReader = annotation.read('entityType');

    if (!entityTypeReader.isType) {
      throw InvalidGenerationSourceError(
        'entityType must be a valid Type.',
        todo: 'Provide a valid Type for entityType.',
      );
    }

    final entityType = entityTypeReader.typeValue;
    final entityElement = entityType.element3;

    if (entityElement is! ClassElement2) {
      throw InvalidGenerationSourceError(
        'entityType must be a class.',
        todo: 'Provide a class type for entityType.',
      );
    }

    final entityClassName = entityElement.firstFragment.name2!;
    final entityVariableName = _camelCase(entityClassName);

    // Get model fields using the Element2 API
    final modelFields = element.fields2
        .where((f) => !f.isStatic && !f.isSynthetic)
        .toList();

    // Get entity fields for validation using the Element2 API
    final entityFields = entityElement.fields2
        .where((f) => !f.isStatic && !f.isSynthetic)
        .toList();

    final buffer = StringBuffer()
      // Generate mapper class
      ..writeln('class ${entityClassName}EntityMapper {')
      ..writeln('  ${entityClassName}EntityMapper._();')
      ..writeln()
      ..writeln('  static ${entityClassName}EntityMapper? _instance;')
      ..writeln('  static ${entityClassName}EntityMapper ensureInitialized() {')
      ..writeln('    return _instance ??= ${entityClassName}EntityMapper._();')
      ..writeln('  }')
      ..writeln()
      // Generate toModel static method
      ..writeln(
        _generateToModelMethod(
          className,
          entityClassName,
          entityVariableName,
          modelFields,
          entityFields,
        ),
      )
      // Generate toEntity static method
      ..writeln(
        _generateToEntityStaticMethod(
          entityClassName,
          className,
          modelFields,
        ),
      )
      ..writeln('}')
      ..writeln()
      // Generate mixin - only with toEntity method
      ..writeln('mixin ${entityClassName}EntityMappable {')
      // Only generate toEntity instance method
      ..writeln(
        _generateToEntityMixinMethod(
          entityClassName,
          className,
        ),
      )
      ..writeln('}')
      ..writeln();

    return buffer.toString();
  }

  String _generateToModelMethod(
    String className,
    String entityClassName,
    String entityVariableName,
    List<FieldElement2> modelFields,
    List<FieldElement2> entityFields,
  ) {
    final buffer = StringBuffer()
      ..writeln(
        '  /// Creates a [$className] from a [$entityClassName] entity',
      )
      ..writeln(
        '  static $className toModel($entityClassName $entityVariableName) {',
      )
      ..writeln('    return $className(');

    for (final field in modelFields) {
      final fieldName = field.firstFragment.name2!;
      final fieldType = field.type;

      // Simple field assignment for now
      final fieldAssignment = _generateFieldAssignment(
        fieldName,
        fieldType,
        entityVariableName,
        entityFields,
      );

      buffer.writeln('      $fieldName: $fieldAssignment,');
    }

    buffer
      ..writeln('    );')
      ..writeln('  }');
    return buffer.toString();
  }

  String _generateToEntityStaticMethod(
    String entityClassName,
    String className,
    List<FieldElement2> modelFields,
  ) {
    final buffer = StringBuffer()
      ..writeln()
      ..writeln('  /// Converts a [$className] to a [$entityClassName] entity')
      ..writeln('  static $entityClassName toEntity($className model) {')
      ..writeln('    return $entityClassName(');

    for (final field in modelFields) {
      final fieldName = field.firstFragment.name2!;
      final fieldType = field.type;

      final fieldAssignment = _generateToEntityFieldAssignment(
        fieldName,
        fieldType,
      );
      buffer.writeln('      $fieldName: $fieldAssignment,');
    }

    buffer
      ..writeln('    );')
      ..writeln('  }');
    return buffer.toString();
  }

  String _generateFieldAssignment(
    String fieldName,
    DartType fieldType,
    String entityVariableName,
    List<FieldElement2> entityFields,
  ) {
    // Check if the entity has this field
    final hasEntityField = entityFields.any(
      (f) => f.firstFragment.name2 == fieldName,
    );

    if (!hasEntityField) {
      throw InvalidGenerationSourceError(
        'Field "$fieldName" not found in entity.',
        todo: 'Add field "$fieldName" to entity.',
      );
    }

    // Handle different field types
    if (_isSimpleType(fieldType)) {
      return '$entityVariableName.$fieldName';
    } else if (_isModelType(fieldType)) {
      // Use the corresponding entity mapper
      final modelTypeName = fieldType.getDisplayString();
      final entityTypeName = _getEntityTypeFromModelType(modelTypeName);
      return '${entityTypeName}EntityMapper.toModel($entityVariableName.$fieldName)';
    } else if (_isListType(fieldType)) {
      final elementType = _getListElementType(fieldType);
      if (_isSimpleType(elementType)) {
        return '$entityVariableName.$fieldName';
      } else if (_isModelType(elementType)) {
        final modelTypeName = elementType.getDisplayString();
        final entityTypeName = _getEntityTypeFromModelType(modelTypeName);
        return '$entityVariableName.$fieldName'
            '.map((e) => ${entityTypeName}EntityMapper.toModel(e)).toList()';
      }
    }

    // Fallback to direct assignment
    return '$entityVariableName.$fieldName';
  }

  String _generateToEntityFieldAssignment(
    String fieldName,
    DartType fieldType,
  ) {
    // Handle different field types
    if (_isSimpleType(fieldType)) {
      return 'model.$fieldName';
    } else if (_isModelType(fieldType)) {
      // Assume the field has a toEntity method
      return 'model.$fieldName.toEntity()';
    } else if (_isListType(fieldType)) {
      final elementType = _getListElementType(fieldType);
      if (_isSimpleType(elementType)) {
        return 'model.$fieldName';
      } else if (_isModelType(elementType)) {
        return 'model.$fieldName.map((e) => e.toEntity()).toList()';
      }
    }

    // Fallback to direct assignment
    return 'model.$fieldName';
  }

  bool _isSimpleType(DartType type) {
    final typeName = type.getDisplayString();
    return [
      'int',
      'double',
      'String',
      'bool',
      'DateTime',
    ].contains(typeName);
  }

  bool _isModelType(DartType type) {
    final typeName = type.getDisplayString();
    // Assume model types end with 'Model'
    return typeName.endsWith('Model');
  }

  bool _isListType(DartType type) {
    return type.isDartCoreList;
  }

  DartType _getListElementType(DartType listType) {
    if (listType is InterfaceType && listType.typeArguments.isNotEmpty) {
      return listType.typeArguments.first;
    }
    throw InvalidGenerationSourceError('Cannot determine list element type');
  }

  String _camelCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }

  String _getEntityTypeFromModelType(String modelTypeName) {
    // Simple convention: remove "Model" suffix to get entity type
    // e.g., "UserModel" -> "User"
    if (modelTypeName.endsWith('Model')) {
      return modelTypeName.substring(0, modelTypeName.length - 5);
    }
    return modelTypeName;
  }

  String _generateToEntityMixinMethod(
    String entityClassName,
    String className,
  ) {
    return '''
  /// Converts this instance to [$entityClassName] entity
  $entityClassName toEntity() {
    return ${entityClassName}EntityMapper.toEntity(this as $className);
  }''';
  }
}
