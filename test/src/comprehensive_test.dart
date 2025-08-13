// ignore_for_file: prefer_const_constructors, document_ignores, avoid_redundant_argument_values

import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../index.dart';

void main() {
  group('Code Generation Tests', () {
    test('annotation validates entity type parameter', () {
      // Test that we can create annotations with real entity types
      final annotation = MapToEntity(User);
      expect(annotation.entityType, equals(User));
    });

    test('field mappings are properly stored', () {
      final annotation = MapToEntity(
        User,
        fieldMappings: {
          'fullName': 'name',
          'userEmail': 'email',
        },
      );

      expect(annotation.fieldMappings, hasLength(2));
      expect(annotation.fieldMappings['fullName'], equals('name'));
      expect(annotation.fieldMappings['userEmail'], equals('email'));
    });

    test('generation flags work correctly', () {
      final onlyToModel = MapToEntity(
        User,
        generateToModel: true,
        generateToEntity: false,
      );

      final onlyToEntity = MapToEntity(
        User,
        generateToModel: false,
        generateToEntity: true,
      );

      expect(onlyToModel.generateToModel, isTrue);
      expect(onlyToModel.generateToEntity, isFalse);
      expect(onlyToEntity.generateToModel, isFalse);
      expect(onlyToEntity.generateToEntity, isTrue);
    });

    test('EntityField annotation handles all combinations', () {
      const defaultField = EntityField();
      const customNameField = EntityField(name: 'custom_name');
      const ignoredField = EntityField(ignore: true);
      const transformedField = EntityField(customTransform: 'value.toString()');
      const complexField = EntityField(
        name: 'complex_field',
        ignore: false,
        customTransform: 'transformValue(value)',
      );

      expect(defaultField.name, isNull);
      expect(defaultField.ignore, isFalse);
      expect(defaultField.customTransform, isNull);

      expect(customNameField.name, equals('custom_name'));
      expect(ignoredField.ignore, isTrue);
      expect(transformedField.customTransform, equals('value.toString()'));

      expect(complexField.name, equals('complex_field'));
      expect(complexField.ignore, isFalse);
      expect(complexField.customTransform, equals('transformValue(value)'));
    });
  });

  group('Error Handling Tests', () {
    test('empty field mappings are handled correctly', () {
      final annotation = MapToEntity(User, fieldMappings: {});
      expect(annotation.fieldMappings, isEmpty);
    });

    test('annotation works with different entity types', () {
      final stringAnnotation = MapToEntity(String);
      final intAnnotation = MapToEntity(int);
      final userAnnotation = MapToEntity(User);

      expect(stringAnnotation.entityType, equals(String));
      expect(intAnnotation.entityType, equals(int));
      expect(userAnnotation.entityType, equals(User));
    });
  });

  group('Real-world Usage Scenarios', () {
    test('typical clean architecture setup', () {
      // This simulates how developers would actually use the annotations
      final annotation = MapToEntity(
        User,
        generateToModel: true,
        generateToEntity: true,
        fieldMappings: {
          'userName': 'name',
          'userEmail': 'email',
        },
      );

      expect(annotation, isNotNull);
      expect(annotation.entityType, equals(User));
      expect(annotation.fieldMappings, containsPair('userName', 'name'));
      expect(annotation.fieldMappings, containsPair('userEmail', 'email'));
    });

    test('read-only model scenario', () {
      final annotation = MapToEntity(
        User,
        generateToModel: true,
        generateToEntity: false, // Only convert FROM entity, not TO entity
      );

      expect(annotation.generateToModel, isTrue);
      expect(annotation.generateToEntity, isFalse);
    });

    test('write-only model scenario', () {
      final annotation = MapToEntity(
        User,
        generateToModel: false, // Only convert TO entity, not FROM entity
        generateToEntity: true,
      );

      expect(annotation.generateToModel, isFalse);
      expect(annotation.generateToEntity, isTrue);
    });
  });
}
