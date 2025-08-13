// ignore_for_file: prefer_const_constructors, document_ignores, avoid_redundant_argument_values

import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Entity Mapper Integration Tests', () {
    test('MapToEntity annotation works with correct parameters', () {
      final annotation = MapToEntity(String);
      expect(annotation.entityType, equals(String));
      expect(annotation.generateToModel, isTrue);
      expect(annotation.generateToEntity, isTrue);
    });

    test('MapToEntity annotation works with custom parameters', () {
      final annotation = MapToEntity(
        String,
        generateToModel: false,
        generateToEntity: true,
        fieldMappings: {'name': 'fullName'},
      );

      expect(annotation.entityType, equals(String));
      expect(annotation.generateToModel, isFalse);
      expect(annotation.generateToEntity, isTrue);
      expect(annotation.fieldMappings, equals({'name': 'fullName'}));
    });

    test('EntityField annotation works correctly', () {
      const field1 = EntityField();
      expect(field1.ignore, isFalse);
      expect(field1.name, isNull);
      expect(field1.customTransform, isNull);

      const field2 = EntityField(
        ignore: true,
        name: 'customName',
        customTransform: 'transform',
      );
      expect(field2.ignore, isTrue);
      expect(field2.name, equals('customName'));
      expect(field2.customTransform, equals('transform'));
    });

    test('annotation types are correct', () {
      expect(MapToEntity(String), isA<MapToEntity>());
      expect(EntityField(), isA<EntityField>());
    });
  });
}
