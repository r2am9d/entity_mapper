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

    test('annotation works with different entity types', () {
      final stringAnnotation = MapToEntity(String);
      final intAnnotation = MapToEntity(int);
      final userAnnotation = MapToEntity(User);

      expect(stringAnnotation.entityType, equals(String));
      expect(intAnnotation.entityType, equals(int));
      expect(userAnnotation.entityType, equals(User));
    });
  });

  group('Error Handling Tests', () {
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
      final annotation = MapToEntity(User);

      expect(annotation, isNotNull);
      expect(annotation.entityType, equals(User));
    });

    test('simple entity mapping scenario', () {
      final annotation = MapToEntity(User);

      expect(annotation.entityType, equals(User));
    });
  });
}
