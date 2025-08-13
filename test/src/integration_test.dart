// ignore_for_file: prefer_const_constructors, document_ignores, avoid_redundant_argument_values

import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Entity Mapper Integration Tests', () {
    test('MapToEntity annotation works with correct parameters', () {
      final annotation = MapToEntity(String);
      expect(annotation.entityType, equals(String));
    });

    test('MapToEntity annotation works with different entity types', () {
      final stringAnnotation = MapToEntity(String);
      final intAnnotation = MapToEntity(int);
      final userAnnotation = MapToEntity(DateTime);

      expect(stringAnnotation.entityType, equals(String));
      expect(intAnnotation.entityType, equals(int));
      expect(userAnnotation.entityType, equals(DateTime));
    });

    test('annotation types are correct', () {
      expect(MapToEntity(String), isA<MapToEntity>());
    });
  });
}
