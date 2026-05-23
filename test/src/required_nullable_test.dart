import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

part 'required_nullable_test.entity_mapper.dart';

/// Model has a required-nullable field (`extra`) with NO counterpart on the
/// `PartialUser` entity. The 0.5.0 generator must pass `null` when building
/// the model from the entity (the "lenient" behavior).
@MapToEntity(PartialUser)
class PartialUserExtraRequiredNullableModel
    with PartialUserExtraRequiredNullableEntityMappable {
  const PartialUserExtraRequiredNullableModel({
    required this.id,
    required this.name,
    required this.extra,
  });

  final String id;
  final String name;
  final String? extra;
}

/// Model has every parameter `required`, every type nullable.
@MapToEntity(RequiredNullable)
class RequiredNullableModel with RequiredNullableEntityMappable {
  const RequiredNullableModel({
    required this.id,
    required this.name,
    required this.age,
  });

  final String? id;
  final String? name;
  final int? age;
}

void main() {
  group('required + nullable model fields', () {
    test('all-required all-nullable preserves null', () {
      const entity = RequiredNullable(id: null, name: null, age: null);
      final model = RequiredNullableEntityMapper.toModel(entity);
      expect(model.id, isNull);
      expect(model.name, isNull);
      expect(model.age, isNull);
    });

    test('all-required all-nullable preserves non-null values', () {
      const entity = RequiredNullable(id: 'x', name: 'Alice', age: 30);
      final model = RequiredNullableEntityMapper.toModel(entity);
      expect(model.id, 'x');
      expect(model.name, 'Alice');
      expect(model.age, 30);
    });
  });

  group('required-nullable model field with NO entity counterpart', () {
    test('toModel passes null for the unfillable required field', () {
      const entity = PartialUser(id: 'u1', name: 'Alice');
      final model = PartialUserExtraRequiredNullableEntityMapper.toModel(
        entity,
      );
      expect(model.id, 'u1');
      expect(model.name, 'Alice');
      // `extra` is required on the model but absent on the entity — the
      // generator inserts a `null` literal so the constructor satisfies the
      // `required` keyword.
      expect(model.extra, isNull);
    });

    test(
      'toEntity from a model carrying the extra field loses it gracefully',
      () {
        const model = PartialUserExtraRequiredNullableModel(
          id: 'u2',
          name: 'Bob',
          extra: 'lost-on-round-trip',
        );
        final back = model.toEntity();
        // `extra` does not exist on PartialUser; data is dropped by design.
        expect(back.id, 'u2');
        expect(back.name, 'Bob');
      },
    );
  });

  // Documented (not exercised here) failure mode:
  //
  //   @MapToEntity(PartialUser)
  //   class BrokenModel with ... {
  //     const BrokenModel({required this.id, required this.name, required this.extra});
  //     final String id;
  //     final String name;
  //     final String extra; // non-nullable + required + absent on entity
  //   }
  //
  // The generator FAILS codegen with InvalidGenerationSourceError naming
  // `extra`. Because that's a compile-time-of-codegen error, it can't be
  // asserted from a unit test — there is nothing to import. The failure
  // surface is covered by manual inspection and CHANGELOG documentation.
}
