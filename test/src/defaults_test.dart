import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

part 'defaults_test.entity_mapper.dart';

/// Model whose fields all have default values — verifies that defaults
/// survive a full entity → model → entity round-trip.
@MapToEntity(WithDefaults)
class WithDefaultsModel with WithDefaultsEntityMappable {
  const WithDefaultsModel({
    this.id = 'default-id',
    this.name = 'default-name',
    this.count = 0,
  });

  final String id;
  final String name;
  final int count;
}

/// Model declares an extra optional field (`extra`) that is NOT on the entity.
/// On `toModel`, the generator should skip the missing field and let its
/// default (`'fallback'`) apply.
@MapToEntity(PartialUser)
class PartialUserExtraOptionalModel
    with PartialUserExtraOptionalEntityMappable {
  const PartialUserExtraOptionalModel({
    required this.id,
    required this.name,
    this.extra = 'fallback',
  });

  final String id;
  final String name;
  final String extra;
}

void main() {
  group('Defaults round-trip', () {
    test('explicit values survive', () {
      const entity = WithDefaults(id: 'x', name: 'Alice', count: 10);
      final back = WithDefaultsEntityMapper.toModel(entity).toEntity();
      expect(back.id, 'x');
      expect(back.name, 'Alice');
      expect(back.count, 10);
    });

    test('entity-side defaults are preserved through the model', () {
      const entity = WithDefaults();
      final back = WithDefaultsEntityMapper.toModel(entity).toEntity();
      expect(back.id, 'default-id');
      expect(back.name, 'default-name');
      expect(back.count, 0);
    });
  });

  group('Model has an optional field absent from the entity', () {
    test('toModel uses the model-side default for the missing field', () {
      const entity = PartialUser(id: 'u1', name: 'Alice');
      final model = PartialUserExtraOptionalEntityMapper.toModel(entity);
      expect(model.id, 'u1');
      expect(model.name, 'Alice');
      // `extra` is not in the entity — model's default applies.
      expect(model.extra, 'fallback');
    });

    test('toEntity ignores the extra model field that has no entity slot', () {
      const model = PartialUserExtraOptionalModel(
        id: 'u2',
        name: 'Bob',
        extra: 'whatever',
      );
      final entity = model.toEntity();
      expect(entity.id, 'u2');
      expect(entity.name, 'Bob');
      // `extra` does not exist on the entity. Lossy by design.
    });
  });
}
