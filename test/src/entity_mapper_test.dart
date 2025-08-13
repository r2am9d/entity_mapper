// ignore_for_file: prefer_const_constructors, document_ignores

import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntityMapper', () {
    test('MapToEntity annotation can be instantiated', () {
      expect(MapToEntity(String), isNotNull);
      expect(MapToEntity(int), isNotNull);
      expect(MapToEntity(DateTime), isNotNull);
    });

    test('MapToEntity annotation stores entityType correctly', () {
      final stringAnnotation = MapToEntity(String);
      final intAnnotation = MapToEntity(int);

      expect(stringAnnotation.entityType, equals(String));
      expect(intAnnotation.entityType, equals(int));
    });
  });
}
