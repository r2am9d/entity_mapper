import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

void main() {
  group('@MapToEntity', () {
    test('can be instantiated with a Type', () {
      const annotation = MapToEntity(User);
      expect(annotation, isA<MapToEntity>());
    });

    test('exposes the entityType passed to the constructor', () {
      const annotation = MapToEntity(User);
      expect(annotation.entityType, User);
    });

    test('different entity types yield distinct annotations', () {
      const a = MapToEntity(User);
      const b = MapToEntity(Address);
      expect(a.entityType, isNot(equals(b.entityType)));
    });

    test('annotation is a const expression', () {
      // If this compiles, the const-ness contract holds. The runtime check
      // is incidental but pins identity behavior for `const` invocations.
      const a = MapToEntity(User);
      const b = MapToEntity(User);
      expect(identical(a, b), isTrue);
    });
  });
}
