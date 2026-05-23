import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
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
      final classElement = annotatedElement.element as ClassElement;
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
    ClassElement element,
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
    final entityElement = entityType.element;
    if (entityElement is! ClassElement) {
      throw InvalidGenerationSourceError(
        'entityType for @$className must be a class.',
        todo: 'Provide a class type for entityType in @$className.',
      );
    }

    // Prepare names and field lists
    final mapperBaseName = _getEntityTypeFromModelType(className);
    final entityVariableName = _camelCase(mapperBaseName);
    final modelFields = element.fields
        .where((f) => !f.isStatic && f.isOriginDeclaration)
        .toList();
    final entityFields = entityElement.fields
        .where((f) => !f.isStatic && f.isOriginDeclaration)
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
    ConstructorElement? entityConstructor;
    for (final ctor in entityElement.constructors) {
      if (ctor.displayName.isEmpty) {
        entityConstructor = ctor;
        break;
      }
    }
    entityConstructor ??= entityElement.constructors.isNotEmpty
        ? entityElement.constructors.first
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

    // Resolve the model's constructor (for the inverse direction: detecting
    // required model fields that have no counterpart in the entity).
    ConstructorElement? modelConstructor;
    for (final ctor in element.constructors) {
      if (ctor.displayName.isEmpty) {
        modelConstructor = ctor;
        break;
      }
    }
    modelConstructor ??= element.constructors.isNotEmpty
        ? element.constructors.first
        : null;

    if (modelConstructor == null) {
      throw InvalidGenerationSourceError(
        'No constructors found for model [$className].',
        todo: 'Add a constructor to your model.',
      );
    }

    // Check for required *non-nullable* fields in model missing from entity.
    // For required *nullable* model fields the generator passes `null`; for
    // non-nullable ones there is no safe value to pass, so fail codegen now.
    final unfillableRequired = <String>[];
    for (final param in modelConstructor.formalParameters) {
      final fieldName = param.displayName;
      final isRequired =
          param.isRequiredNamed ||
          param.isRequiredPositional ||
          (!param.isOptional);
      if (!isRequired || commonFieldNames.contains(fieldName)) continue;
      final field = modelFields.firstWhere(
        (f) => f.displayName == fieldName,
        orElse: () => throw InvalidGenerationSourceError(
          'Constructor parameter "$fieldName" on model [$className] does not '
          'correspond to any field declared on the class.',
        ),
      );
      final isNullable =
          field.type.nullabilitySuffix == NullabilitySuffix.question;
      if (!isNullable) {
        unfillableRequired.add(fieldName);
      }
    }
    if (unfillableRequired.isNotEmpty) {
      throw InvalidGenerationSourceError(
        'Required non-nullable field(s) [${unfillableRequired.join(', ')}] in '
        'model [$className] have no counterpart in entity '
        '[${entityElement.displayName}]. The generator has no safe value to '
        'pass when constructing the model from the entity.',
        todo:
            'Add these fields to the entity, make them optional in the model,'
            ' or change their types to be nullable.',
      );
    }

    // Multi-error reporting for nullability mismatches between entity and model
    final nullabilityErrors = <String>[];
    for (final fieldName in commonFieldNames) {
      FieldElement? modelField;
      for (final f in modelFields) {
        if (f.displayName == fieldName) {
          modelField = f;
          break;
        }
      }
      FieldElement? entityField;
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
          modelConstructor,
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
  ///
  /// Iterates the model's constructor parameters so the emitted call satisfies
  /// every required argument:
  /// - parameters whose name is in [commonFieldNames] are mapped from the
  ///   entity via [_generateFieldAssignment];
  /// - required-but-not-in-entity parameters of nullable type are passed
  ///   `null` (the codegen has already validated non-nullable cases);
  /// - optional-and-not-in-entity parameters are skipped so their defaults
  ///   apply.
  String _generateToModelMethodStrict(
    String className,
    String entityClassName,
    String entityVariableName,
    List<FieldElement> modelFields,
    List<FieldElement> entityFields,
    Set<String> commonFieldNames,
    ConstructorElement modelConstructor,
  ) {
    final buffer = StringBuffer()
      ..writeln('  /// Creates a [$className] from a [$entityClassName] entity')
      ..writeln('  static $className toModel($entityClassName entity) {')
      ..writeln('    return $className(');
    for (final param in modelConstructor.formalParameters) {
      final fieldName = param.displayName;
      final isRequired =
          param.isRequiredNamed ||
          param.isRequiredPositional ||
          (!param.isOptional);
      if (commonFieldNames.contains(fieldName)) {
        final field = modelFields.firstWhere((f) => f.displayName == fieldName);
        final fieldType = field.type;
        final fieldAssignment = _generateFieldAssignment(
          fieldName,
          fieldType,
          className,
          entityClassName,
        );
        buffer.writeln('      $fieldName: $fieldAssignment,');
      } else if (isRequired) {
        // Pre-validated to be nullable; pass null.
        buffer.writeln('      $fieldName: null,');
      }
      // else: optional parameter not in entity — skip so its default applies.
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
    List<FieldElement> modelFields,
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

  /// Generates the right-hand expression for a model constructor argument
  /// when converting an entity to a model.
  ///
  /// Three cases:
  /// 1. `List<XModel>` (nullable or not) — `entity.field(?).map(XEntityMapper.toModel).toList()`.
  /// 2. A non-list nested model type ending in `Model` — call the matching
  ///    mapper. For a nullable type, guard with `field == null ? null : ...`.
  /// 3. Primitives and other non-mappable types — direct passthrough.
  String _generateFieldAssignment(
    String fieldName,
    DartType fieldType,
    String modelClassName,
    String entityClassName,
  ) {
    // Case 1: List<XModel>
    if (fieldType is ParameterizedType &&
        fieldType.typeArguments.length == 1 &&
        (fieldType.element?.displayName == 'List')) {
      final itemType = fieldType.typeArguments.first;
      final itemTypeName = itemType.getDisplayString();
      if (itemTypeName.endsWith('Model')) {
        final entityTypeName = itemTypeName.substring(
          0,
          itemTypeName.length - 5,
        );
        final mapperName = '${entityTypeName}EntityMapper';
        final isNullable =
            fieldType.nullabilitySuffix == NullabilitySuffix.question;
        final accessor = isNullable ? '?.' : '.';
        return 'entity.$fieldName${accessor}map($mapperName.toModel).toList()';
      }
    }

    // Case 2: non-list nested model type ending in `Model`.
    final displayed = fieldType.getDisplayString();
    final isNullable =
        fieldType.nullabilitySuffix == NullabilitySuffix.question;
    final cleanedTypeName = isNullable
        ? displayed.substring(0, displayed.length - 1)
        : displayed;
    if (cleanedTypeName.endsWith('Model')) {
      final entityTypeName = cleanedTypeName.substring(
        0,
        cleanedTypeName.length - 5,
      );
      final mapperName = '${entityTypeName}EntityMapper';
      if (isNullable) {
        return 'entity.$fieldName == null ? null : '
            '$mapperName.toModel(entity.$fieldName!)';
      }
      return '$mapperName.toModel(entity.$fieldName)';
    }

    // Case 3: primitive / non-mappable — direct.
    return 'entity.$fieldName';
  }

  /// Generates the right-hand expression for an entity constructor argument
  /// when converting a model to an entity. Mirror of [_generateFieldAssignment]
  /// in the opposite direction.
  String _generateToEntityFieldAssignment(
    String fieldName,
    DartType fieldType,
    String modelClassName,
    String entityClassName,
  ) {
    // Case 1: List<XModel>
    if (fieldType is ParameterizedType &&
        fieldType.typeArguments.length == 1 &&
        (fieldType.element?.displayName == 'List')) {
      final itemType = fieldType.typeArguments.first;
      final itemTypeName = itemType.getDisplayString();
      if (itemTypeName.endsWith('Model')) {
        final entityTypeName = itemTypeName.substring(
          0,
          itemTypeName.length - 5,
        );
        final mapperName = '${entityTypeName}EntityMapper';
        final isNullable =
            fieldType.nullabilitySuffix == NullabilitySuffix.question;
        final accessor = isNullable ? '?.' : '.';
        return 'model.$fieldName${accessor}map($mapperName.toEntity).toList()';
      }
    }

    // Case 2: non-list nested model type ending in `Model`.
    final displayed = fieldType.getDisplayString();
    final isNullable =
        fieldType.nullabilitySuffix == NullabilitySuffix.question;
    final cleanedTypeName = isNullable
        ? displayed.substring(0, displayed.length - 1)
        : displayed;
    if (cleanedTypeName.endsWith('Model')) {
      final entityTypeName = cleanedTypeName.substring(
        0,
        cleanedTypeName.length - 5,
      );
      final mapperName = '${entityTypeName}EntityMapper';
      if (isNullable) {
        return 'model.$fieldName == null ? null : '
            '$mapperName.toEntity(model.$fieldName!)';
      }
      return '$mapperName.toEntity(model.$fieldName)';
    }

    // Case 3: primitive / non-mappable — direct.
    return 'model.$fieldName';
  }
}
