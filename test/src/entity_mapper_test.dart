// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntityMapper', () {
    test('can be instantiated', () {
      expect(EntityMapper(), isNotNull);
    });
  });
}
