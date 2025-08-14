import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:entity_mapper/src/annotations/map_to_entity.dart';
import 'package:source_gen/source_gen.dart';

/// Builder entry point for Entity Mapper code generation.
/// This builder scans for classes annotated with @MapToEntity and generates
/// strict entity ↔ model mapping code for each.
Builder entityMapperBuilder(BuilderOptions options) => LibraryBuilder(
  EntityMapperGenerator(),
  generatedExtension: '.entity_mapper.dart',
);

/// Main generator for entity ↔ model mapping code.
/// - Only fields present in both model and entity are mapped.
/// - If a required field in the entity is missing from the model, code generation fails.
/// - Unmapped fields are logged as warnings.
/// - All nullability mismatches between entity and model fields are reported in a single error.
class EntityMapperGenerator extends Generator {
  /// Scans the library for @MapToEntity annotations and generates mapping code.
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    // Find all classes annotated with @MapToEntity
    const checker = TypeChecker.typeNamed(
      MapToEntity,
      inPackage: 'entity_mapper',
    );
    final annotated = library.annotatedWith(checker);
    if (annotated.isEmpty) {
      return '';
    }

    // Start generated file with part directive
    final buffer = StringBuffer()
      ..writeln("part of '${buildStep.inputId.path.split('/').last}';")
      ..writeln();

    // Generate mapping code for each annotated class
    for (final annotatedElement in annotated) {
      final classElement = annotatedElement.element as ClassElement2;
      buffer.writeln(
        _generateForElement(
          classElement,
          annotatedElement.annotation.objectValue,
          buildStep,
        ),
      );
    }

    return buffer.toString();
  }

  /// Generates mapping code for a single annotated model class.
  /// Performs strict field matching and multi-error reporting for nullability.
  String _generateForElement(
    ClassElement2 element,
    DartObject? annotation,
    BuildStep buildStep,
  ) {
    // Read annotation and extract entity type
    final annotationReader = ConstantReader(annotation);
    final className = element.displayName;
    final entityTypeReader = annotationReader.read('entityType');
    if (!entityTypeReader.isType) {
      throw InvalidGenerationSourceError(
        'entityType for @$className must be a valid Type.',
        todo: 'Provide a valid Type for entityType in @$className.',
      );
    }
    final entityType = entityTypeReader.typeValue;
    final entityElement = entityType.element3;
    if (entityElement is! ClassElement2) {
      throw InvalidGenerationSourceError(
        'entityType for @$className must be a class.',
        todo: 'Provide a class type for entityType in @$className.',
      );
    }

    // Prepare names and field lists
    final mapperBaseName = _getEntityTypeFromModelType(className);
    final entityVariableName = _camelCase(mapperBaseName);
    final modelFields = element.fields2
        .where((f) => !f.isStatic && !f.isSynthetic)
        .toList();
    final entityFields = entityElement.fields2
        .where((f) => !f.isStatic && !f.isSynthetic)
        .toList();
    final modelFieldNames = modelFields.map((f) => f.displayName).toSet();
    final entityFieldNames = entityFields.map((f) => f.displayName).toSet();
    final commonFieldNames = modelFieldNames.intersection(entityFieldNames);
    final unmappedModelFields = modelFieldNames.difference(entityFieldNames);
    final unmappedEntityFields = entityFieldNames.difference(modelFieldNames);

    // Warn about unmapped fields
    if (unmappedModelFields.isNotEmpty) {
      log.warning(
        'Unmapped model fields in $className: ${unmappedModelFields.join(', ')}',
      );
    }
    if (unmappedEntityFields.isNotEmpty) {
      log.warning(
        'Unmapped entity fields in ${entityElement.displayName}: ${unmappedEntityFields.join(', ')}',
      );
    }

    // Strict: fail if any required field in entity is missing from model
    ConstructorElement2? entityConstructor;
    for (final ctor in entityElement.constructors2) {
      if (ctor.displayName.isEmpty) {
        entityConstructor = ctor;
        break;
      }
    }
    entityConstructor ??= entityElement.constructors2.isNotEmpty
        ? entityElement.constructors2.first
        : null;

    if (entityConstructor == null) {
      throw InvalidGenerationSourceError(
        'No constructors found for entity [${entityElement.displayName}].',
        todo: 'Add a constructor to your entity.',
      );
    }
    // Check for required fields in entity missing from model
    for (final param in entityConstructor.formalParameters) {
      final fieldName = param.displayName;
      final isRequired =
          param.isRequiredNamed ||
          param.isRequiredPositional ||
          (!param.isOptional);
      if (isRequired && !modelFieldNames.contains(fieldName)) {
        throw InvalidGenerationSourceError(
          'Required field "$fieldName" in entity [${entityElement.displayName}] is missing from model [$className].',
          todo: 'Add "$fieldName" to model or make it optional in entity.',
        );
      }
    }

    // Multi-error reporting for nullability mismatches between entity and model
    final nullabilityErrors = <String>[];
    for (final fieldName in commonFieldNames) {
      FieldElement2? modelField;
      for (final f in modelFields) {
        if (f.displayName == fieldName) {
          modelField = f;
          break;
        }
      }
      FieldElement2? entityField;
      for (final f in entityFields) {
        if (f.displayName == fieldName) {
          entityField = f;
          break;
        }
      }
      if (modelField != null && entityField != null) {
        final modelType = modelField.type;
        final entityType = entityField.type;
        final modelTypeStr = modelType.getDisplayString();
        final entityTypeStr = entityType.getDisplayString();
        final modelIsNullable = modelTypeStr.endsWith('?');
        final entityIsNullable = entityTypeStr.endsWith('?');
        if (!modelIsNullable && entityIsNullable) {
          nullabilityErrors.add(
            'Nullability mismatch for field "$fieldName": model [$className] requires non-nullable, but entity [${entityElement.displayName}] allows null.\n  Fix: Make "$fieldName" non-nullable in entity or nullable in model.',
          );
        }
      }
    }

    // Throw a single error listing all nullability mismatches
    if (nullabilityErrors.isNotEmpty) {
      throw InvalidGenerationSourceError(
        nullabilityErrors.join('\n\n'),
        todo: 'Resolve all listed nullability mismatches.',
      );
    }

    // Generate the mapping class and mixin
    final buffer = StringBuffer()
      ..writeln('class ${mapperBaseName}EntityMapper {')
      ..writeln('  ${mapperBaseName}EntityMapper._();')
      ..writeln()
      ..writeln('  static ${mapperBaseName}EntityMapper? _instance;')
      ..writeln('  static ${mapperBaseName}EntityMapper ensureInitialized() {')
      ..writeln('    return _instance ??= ${mapperBaseName}EntityMapper._();')
      ..writeln('  }')
      ..writeln()
      ..writeln(
        _generateToModelMethodStrict(
          className,
          entityElement.displayName,
          entityVariableName,
          modelFields,
          entityFields,
          commonFieldNames,
        ),
      )
      ..writeln(
        _generateToEntityStaticMethodStrict(
          entityElement.displayName,
          className,
          modelFields,
          commonFieldNames,
        ),
      )
      ..writeln('}')
      ..writeln('mixin ${mapperBaseName}EntityMappable {')
      ..writeln(
        _generateToEntityMixinMethod(
          entityElement.displayName,
          className,
          mapperBaseName,
        ),
      )
      ..writeln('}')
      ..writeln();
    return buffer.toString();
  }

  /// Generates static method to convert entity to model.
  String _generateToModelMethodStrict(
    String className,
    String entityClassName,
    String entityVariableName,
    List<FieldElement2> modelFields,
    List<FieldElement2> entityFields,
    Set<String> commonFieldNames,
  ) {
    final buffer = StringBuffer()
      ..writeln('  /// Creates a [$className] from a [$entityClassName] entity')
      ..writeln('  static $className toModel($entityClassName entity) {')
      ..writeln('    return $className(');
    for (final fieldName in commonFieldNames) {
      final field = modelFields.firstWhere((f) => f.displayName == fieldName);
      final fieldType = field.type;
      final fieldAssignment = _generateFieldAssignment(
        fieldName,
        fieldType,
        className,
        entityClassName,
      );
      buffer.writeln('      $fieldName: $fieldAssignment,');
    }
    buffer
      ..writeln('    );')
      ..writeln('  }');
    return buffer.toString();
  }

  /// Generates static method to convert model to entity.
  String _generateToEntityStaticMethodStrict(
    String entityClassName,
    String className,
    List<FieldElement2> modelFields,
    Set<String> commonFieldNames,
  ) {
    final buffer = StringBuffer()
      ..writeln()
      ..writeln('  /// Converts a [$className] to a [$entityClassName] entity')
      ..writeln('  static $entityClassName toEntity($className model) {')
      ..writeln('    return $entityClassName(');
    for (final fieldName in commonFieldNames) {
      final field = modelFields.firstWhere((f) => f.displayName == fieldName);
      final fieldType = field.type;
      final fieldAssignment = _generateToEntityFieldAssignment(
        fieldName,
        fieldType,
        className,
        entityClassName,
      );
      buffer.writeln('      $fieldName: $fieldAssignment,');
    }
    buffer
      ..writeln('    );')
      ..writeln('  }');
    return buffer.toString();
  }

  /// Converts a string to camelCase.
  String _camelCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }

  /// Strips 'Model' suffix from type name to get entity type.
  String _getEntityTypeFromModelType(String modelTypeName) {
    if (modelTypeName.endsWith('Model')) {
      return modelTypeName.substring(0, modelTypeName.length - 5);
    }
    return modelTypeName;
  }

  /// Generates mixin method for converting model instance to entity.
  String _generateToEntityMixinMethod(
    String entityClassName,
    String className,
    String mapperBaseName,
  ) {
    return '''
  /// Converts this instance to [$entityClassName] entity
  $entityClassName toEntity() {
    return ${mapperBaseName}EntityMapper.toEntity(this as $className);
  }''';
  }

  /// Handles mapping for `List<T>` fields where T is a mappable type.
  String _generateFieldAssignment(
    String fieldName,
    DartType fieldType,
    String modelClassName,
    String entityClassName,
  ) {
    if (fieldType is ParameterizedType &&
        fieldType.typeArguments.length == 1 &&
        (fieldType.element3?.displayName == 'List')) {
      final itemType = fieldType.typeArguments.first;
      final itemTypeName = itemType.getDisplayString();
      // If itemType ends with 'Model', map from entity to model
      if (itemTypeName.endsWith('Model')) {
        final entityTypeName = itemTypeName.substring(
          0,
          itemTypeName.length - 5,
        );
        final mapperName = '${entityTypeName}EntityMapper';
        return 'entity.$fieldName.map($mapperName.toModel).toList()';
      }
    }
    // Direct assignment for primitive or non-mappable types
    return 'entity.$fieldName';
  }

  /// Handles mapping for `List<T>` fields where T is a mappable type.
  String _generateToEntityFieldAssignment(
    String fieldName,
    DartType fieldType,
    String modelClassName,
    String entityClassName,
  ) {
    if (fieldType is ParameterizedType &&
        fieldType.typeArguments.length == 1 &&
        (fieldType.element3?.displayName == 'List')) {
      final itemType = fieldType.typeArguments.first;
      final itemTypeName = itemType.getDisplayString();
      // If itemType ends with 'Model', map from model to entity
      if (itemTypeName.endsWith('Model')) {
        final entityTypeName = itemTypeName.substring(
          0,
          itemTypeName.length - 5,
        );
        final mapperName = '${entityTypeName}EntityMapper';
        return 'model.$fieldName.map($mapperName.toEntity).toList()';
      }
    }
    // Direct assignment for primitive or non-mappable types
    return 'model.$fieldName';
  }
}
