import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

part 'mixin_test.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({
    required this.id,
    required this.name,
    required this.age,
  });

  final String id;
  final String name;
  final int age;
}

void main() {
  group('XEntityMappable mixin', () {
    const model = UserModel(id: 'u1', name: 'Alice', age: 30);

    test('instance method toEntity() returns the entity', () {
      final entity = model.toEntity();
      expect(entity, isA<User>());
      expect(entity.id, 'u1');
      expect(entity.name, 'Alice');
      expect(entity.age, 30);
    });

    test('toEntity() instance method matches the static toEntity', () {
      final viaMixin = model.toEntity();
      final viaStatic = UserEntityMapper.toEntity(model);
      expect(viaMixin.id, viaStatic.id);
      expect(viaMixin.name, viaStatic.name);
      expect(viaMixin.age, viaStatic.age);
    });

    test('ensureInitialized returns a singleton', () {
      final a = UserEntityMapper.ensureInitialized();
      final b = UserEntityMapper.ensureInitialized();
      expect(identical(a, b), isTrue);
    });
  });
}
