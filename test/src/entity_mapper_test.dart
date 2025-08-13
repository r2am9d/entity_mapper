// ignore_for_file: prefer_const_constructors, document_ignores

import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntityMapper', () {
    test('MapToEntity annotation can be instantiated', () {
      expect(MapToEntity(String), isNotNull);
    });

    test('EntityField annotation can be instantiated', () {
      expect(EntityField(), isNotNull);
      expect(EntityField(ignore: true), isNotNull);
      expect(EntityField(name: 'customName'), isNotNull);
    });
  });
}
